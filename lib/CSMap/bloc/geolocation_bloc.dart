import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

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
      if (!isEnabled)
        add(GeolocationErrorDetected(status: GeolocationStatus.LocationServiceDisabled));
      else if (currentPermission == LocationPermission.denied ||
          currentPermission == LocationPermission.denied ||
          currentPermission == null) {
        add(RequestPermission());
      } else {
        Position currPos = await Geolocator.getCurrentPosition();
        lastKnownPosition = CSPosition.fromMap(currPos.toJson());
        if (startRequest)
          add(StartGeolocation());
        else {
         print("Geolocator is ready");
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
      Geolocator.requestPermission().then((LocationPermission locationPermission) {
        if (locationPermission == LocationPermission.denied || locationPermission != LocationPermission.deniedForever)
          add(GeolocationErrorDetected(status: GeolocationStatus.NoPermission));
        else
          add(InitializeGeolocator());
      });
    }
    if (event is UpdatePosition) {
      print("Position updated: ${event.position.toJson()}");
      yield PositionUpdated(position: event.position);
    }
    if (event is GeolocationErrorDetected) {

    }
    if (event is CloseGeolocationStream) {
      startRequest = false;
      positionStream.cancel();
    }
  }
}
