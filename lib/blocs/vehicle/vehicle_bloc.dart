import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/UploadService.dart';
import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../navigation.dart';
import '../../serviceLocator.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial());
  final NavigationService navService = locator<NavigationService>();
  final UploadService uploadService = locator<UploadService>();
  final ApiService apiService = locator<ApiService>();
  final AuthService authService = locator<AuthService>();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Stream<VehicleState> mapEventToState(
    VehicleEvent event,
  ) async* {
    if (event is SetSelectedVehicle){
      print("Updating selected vehicle: ${event.vehicle.plateNumber}");
      await db.collection("users").doc(locator<AuthService>().currentUser().uid).update({"currentVehicle": event.vehicle.plateNumber});
    }
    if (event is AddVehicleEvent) {
      var payload = {
        "OR": event.OR,
        "CR": event.CR,
        "vehicleImage": event.vehicleImage,
        "make": event.make,
        "model": event.model,
        "plateNumber": event.plateNumber,
        "type": event.type,
        "color": event.color
      };
      navService.pushReplaceNavigateTo(DashboardRoute);
      Response res = await apiService.addVehicle((authService.currentUser()).uid, payload);
      // if (res.statusCode == 201) {
      //   if (event.fromHomeScreen) {
      //     navService.goBack();
      //   } else {
      //     setPushTokenCache();
      //     cache.put(authService.currentUser().uid, {"skipVehicle": false});
      //     navService.pushReplaceNavigateTo(DashboardRoute);
      //   }
      // } else
      //   yield LoginError(message: res.error.toString());
    }
  }
}
