import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_repo_event.dart';
part 'vehicle_repo_state.dart';

class VehicleRepoBloc extends Bloc<VehicleRepoEvent, VehicleRepoState> {
  VehicleRepoBloc() : super(VehicleRepoInitial());
  StreamSubscription<QuerySnapshot> vehicles;
  bool expireWarning = true;
  @override
  Stream<VehicleRepoState> mapEventToState(
    VehicleRepoEvent event,
  ) async* {
    if (event is InitializeVehicleRepo) {
      print("Initializing Vehicle Repo");
      yield VehicleRepoInitial();
      try {
        vehicles = FirebaseFirestore.instance
            .collection("vehicles")
            .where("currentUsers", arrayContains: event.uid)
            .snapshots()
            .listen((result) {
          List<Vehicle> vehicles = [];
          HashMap<String,Vehicle> vehiclesMap = HashMap<String,Vehicle>();
          for (DocumentSnapshot doc in result.docs) {
            Vehicle v = Vehicle.fromDoc(doc);
            if (v.expireDate.isBefore(DateTime.now().add(Duration(days: 7)))) {
              print("A vehicle will expire");
              if (expireWarning) {
                print(expireWarning);
                try {
                  if (locator<AuthService>().currentUser().uid == v.ownerId)
                    FirebaseFirestore.instance
                        .collection("archive")
                        .doc(locator<AuthService>().currentUser().uid)
                        .collection("notifications")
                        .add(CSNotification(
                            opened: false,
                            title: "Your vehicle ${v.plateNumber} is expiring soon!",
                            dateCreated: DateTime.now(),
                            type: NotificationType.ExpiringVehicle,
                            data: {
                              "message": "Your vehicle will expire by ${formatDate(v.expireDate, [
                                MM,
                                " ",
                                dd,
                                ", ",
                                yyyy,
                              ])}. Please update your vehicle registration details at the soonest possible time.",
                            }).toJson());
                  if (expireWarning) expireWarning = false;
                } catch (e) {
                  print(e);
                }
              }
            }
            vehiclesMap.putIfAbsent(v.plateNumber, () => v);
            vehicles.add(v);
          }
          print("Number of vehicles ${vehicles.length}");
          print(vehiclesMap.entries);
          add(UpdateVehicleRepo(vehicles: vehicles, vehiclesCollection: vehiclesMap));
        });
      } catch (e) {
        print("Initialize VehicleRepo Error");
        print(e);
      }
    }
    if (event is UpdateVehicleRepo) {
      print("New update to vehicles repo");
      yield VehicleRepoReady(vehicles: event.vehicles, vehiclesCollection: event.vehiclesCollection);
    }
    if (event is DisposeVehicleRepo) {
      print("VehicleRepoCalledDispose");
      await vehicles.cancel();
      yield VehicleRepoInitial();
    }
  }
}
