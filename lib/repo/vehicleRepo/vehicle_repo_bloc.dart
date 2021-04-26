import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_repo_event.dart';
part 'vehicle_repo_state.dart';

class VehicleRepoBloc extends Bloc<VehicleRepoEvent, VehicleRepoState> {
  VehicleRepoBloc() : super(VehicleRepoInitial());
  StreamSubscription<QuerySnapshot> vehicles;

  @override
  Stream<VehicleRepoState> mapEventToState(
    VehicleRepoEvent event,
  ) async* {
    if (event is InitializeVehicleRepo) {
      yield VehicleRepoInitial();
        vehicles = FirebaseFirestore.instance
            .collection("vehicles")
            .where("currentUsers", arrayContains: event.uid)
            .snapshots()
            .listen((result) {
          List<Vehicle> vehicles = [];
          for (DocumentSnapshot doc in result.docs) {
            vehicles.add(Vehicle.fromDoc(doc));
          }
          add(UpdateVehicleRepo(vehicles: vehicles));
        });
    }
    if (event is UpdateVehicleRepo) {
      print("New update to vehicles repo");
      yield VehicleRepoReady(vehicles: event.vehicles);
    }
    if (event is DisposeVehicleRepo) {
      print("VehicleRepoCalledDispose");
      await vehicles.cancel();
      yield VehicleRepoInitial();
    }
  }
}
