import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/UploadService.dart';
import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../navigation.dart';
import '../../serviceLocator.dart';

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
    if (event is SetSelectedVehicle){
      print("Updating selected vehicle: ${event.vehicle.plateNumber}");
      await _db.collection("users").doc(_authService.currentUser().uid).update({"currentVehicle": event.vehicle.plateNumber});
    }
    if (event is RevokeVehiclePermission){
      await _db.collection("vehicles").doc(event.vehicle.plateNumber).update({"currentUsers": FieldValue.arrayRemove([event.uid])});
    }
    if (event is RemoveVehicle){
      await _db.collection("vehicles").doc(event.vehicle.plateNumber).update({"currentUsers": FieldValue.arrayRemove([_authService.currentUser().uid])});
      await _db.collection("users").doc(_authService.currentUser().uid).update({"vehicles": FieldValue.arrayRemove([event.vehicle.plateNumber])});
    }
    if (event is UpdateVehicleDetails){
      await _db.collection("vehicles").doc(event.vehicle.plateNumber).update(event.vehicle.toJson());
      _navService.goBack();
    }
    if (event is DeleteVehicle){
      await _db.collection("vehicles").doc(event.vehicle.plateNumber).delete();
    }
    if (event is AddVehicle) {
      await _db.collection("vehicles").doc(event.vehicle.plateNumber).set(event.vehicle.toJson());
      await _db.collection("users").doc(_authService.currentUser().uid).update({"vehicles": FieldValue.arrayUnion([event.vehicle.plateNumber])});
      _navService.goBack();
    }
  }
}
