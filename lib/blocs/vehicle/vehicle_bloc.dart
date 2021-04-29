import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/CSNotification.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial());
  final NavigationService _navService = locator<NavigationService>();
  final AuthService _authService = locator<AuthService>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Stream<VehicleState> mapEventToState(
    VehicleEvent event,
  ) async* {
    if (event is SetSelectedVehicle) {
      print("Updating selected user: ${_authService.currentUser().uid}");
      print("Updating selected vehicle: ${event.vehicle.plateNumber}");
      try {
        await _db
            .collection("users")
            .doc(_authService.currentUser().uid)
            .update({"currentVehicle": event.vehicle.plateNumber});
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is RevokeVehiclePermission) {
      try {
        await _db.collection("vehicles").doc(event.vehicle.plateNumber).update({
          "currentUsers": FieldValue.arrayRemove([event.uid])
        });
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is RemoveVehicle) {
      try {
        await _db.collection("vehicles").doc(event.vehicle.plateNumber).update({
          "currentUsers": FieldValue.arrayRemove([_authService.currentUser().uid])
        });
        await _db.collection("users").doc(_authService.currentUser().uid).update({
          "vehicles": FieldValue.arrayRemove([event.vehicle.plateNumber])
        });
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is UpdateVehicleDetails) {
      try {
        await _db.collection("vehicles").doc(event.vehicle.plateNumber).update(event.vehicle.toJson());
        _navService.goBack();
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is DeleteVehicle) {
      try {
        await _db.collection("vehicles").doc(event.vehicle.plateNumber).delete();
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is AddVehicle) {
      try {
        await _db.collection("vehicles").doc(event.vehicle.plateNumber).set(event.vehicle.toJson());
        await _db.collection("users").doc(_authService.currentUser().uid).update({
          "vehicles": FieldValue.arrayUnion([event.vehicle.plateNumber])
        });
        FirebaseFirestore.instance
            .collection("archive")
            .doc(locator<AuthService>().currentUser().uid)
            .collection("notifications")
            .add(CSNotification(
                opened: false,
                title: "Vehicle Registration Successful",
                dateCreated: DateTime.now(),
                type: NotificationType.ExpiringVehicle,
                data: {
                  "message":
                      "Your vehicle ${event.vehicle.plateNumber} with registration expiry ${formatDate(event.vehicle.expireDate, [
                    MM,
                    " ",
                    dd,
                    ", ",
                    yyyy,
                  ])} has been added. Please allow 15-45 minutes for verification.",
                }).toJson());
        _navService.goBack();
      } catch (e) {
        add(VehicleBlocError(error: e));
      }
    }
    if (event is VehicleBlocError) {
      print(event.error);
    }
  }
}
