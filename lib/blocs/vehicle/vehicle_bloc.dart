import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../serviceLocator.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial());
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Stream<VehicleState> mapEventToState(
    VehicleEvent event,
  ) async* {
    if (event is SetSelectedVehicle){
      print("Updating selected vehicle: ${event.vehicle.plateNumber}");
      await db.collection("users").doc(locator<AuthService>().currentUser().uid).update({"currentVehicle": event.vehicle.plateNumber});
      yield VehicleInitial();
    }
  }
}
