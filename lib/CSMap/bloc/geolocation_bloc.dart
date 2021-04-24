import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  StreamSubscription<Position> positionStream;
  CSPosition lastKnownPosition;
  bool ready = false;
  bool startRequest = false;
  GeolocationBloc() : super(GeolocationInitial());
  @override
  Stream<GeolocationState> mapEventToState(
    GeolocationEvent event,
  ) async* {
    print("Geolocator event");
    print(event);
    if (event is InitializeGeolocator) {
      print("INITIALIZING GEOLOCATION");
      bool isEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission currentPermission = await Geolocator.checkPermission();
      print(currentPermission);
      if (!isEnabled)
        add(GeolocationErrorDetected(status: GeolocationError.LocationServiceDisabled));
      else if (currentPermission == LocationPermission.denied ||
          currentPermission == LocationPermission.deniedForever ||
          currentPermission == null) {
        add(RequestPermission());
      } else {
        // print("StartRequest $startRequest");
        // print("Ready $ready");
        Position currPos = await Geolocator.getCurrentPosition();
        lastKnownPosition = CSPosition.fromMap(currPos.toJson());
        if (startRequest)
          add(StartGeolocation());
        else {
          print("Geolocator is ready");
          ready = true;
          yield GeolocatorReady();
        }
      }
    }
    if (event is StartGeolocation) {
      startRequest = true;
      if (ready)
        positionStream = Geolocator.getPositionStream(
                desiredAccuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 1,
                intervalDuration: Duration(seconds: 5))
            .listen((Position v) {
          lastKnownPosition = CSPosition.fromMap(v.toJson());
          add(UpdatePosition(position: lastKnownPosition));
        });
      else
        add(InitializeGeolocator());
    }
    if (event is RequestPermission) {
      LocationPermission currentPermission = await Geolocator.requestPermission();
      // print("Permission after it is shown $currentPermission");
      if (currentPermission == LocationPermission.denied ||
          currentPermission == LocationPermission.deniedForever ||
          currentPermission == null) {
        add(GeolocationErrorDetected(status: GeolocationError.NoPermission));
      } else
        add(InitializeGeolocator());
    }
    if (event is UpdatePosition) {
      print("Position updated: ${event.position.toJson()}");
      yield PositionUpdated(position: event.position);
    }
    if (event is UpdatePositionManual) {
      print("Position updated manually: ${event.position.toJson()}");
      yield PositionUpdated(position: event.position);
    }
    if (event is GeolocationErrorDetected) {
      if (event.status == GeolocationError.LocationServiceDisabled)
        PopUp.showInfo(
            context: locator<NavigationService>().navigatorKey.currentContext,
            title: "Location Services Disabled",
            body: "CarSpace needs geolocation services to work",
            onAcknowledge: () async {
              bool enabled = await Geolocator.openLocationSettings();
              print("Opening location settings");
              print(enabled);
              locator<NavigationService>()
                  .navigatorKey
                  .currentContext
                  .read<GeolocationBloc>()
                  .add(InitializeGeolocator());
            });
      if (event.status == GeolocationError.NoPermission)
        PopUp.showInfo(
            context: locator<NavigationService>().navigatorKey.currentContext,
            title: "Please give CarSpace geolocation service permission.",
            body: "CarSpace needs geolocation services to work",
            onAcknowledge: () async {
              locator<NavigationService>().navigatorKey.currentContext.read<GeolocationBloc>().add(RequestPermission());
            });
    }
    if (event is CloseGeolocationStream) {
      print("Closing Geolocation Stream");
      startRequest = false;
      ready= false;
      positionStream?.cancel();
      add(InitializeGeolocator());
    }
  }
}
