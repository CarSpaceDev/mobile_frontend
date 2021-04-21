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
  GeolocationBloc() : super(GeolocationInitial());
  @override
  Stream<GeolocationState> mapEventToState(
    GeolocationEvent event,
  ) async* {
    print("Geolocator State");
    print(event);
    if (event is InitializeGeolocation) {
      print("Initializing Geolocation");
      Geolocator.isLocationServiceEnabled().then((bool value) {
        if (value) {
          Geolocator.checkPermission().then((LocationPermission v) {
            if (v != null && v == LocationPermission.denied || v == LocationPermission.deniedForever) {
              add(RequestPermission());
            } else {
              add(StartGeolocatorStream());
            }
          });
        } else {
          add(GeolocationErrorDetected(status: GeolocationStatus.NoPermission));
        }
      });
    }
    if (event is RequestPermission) {
      Geolocator.requestPermission().then((LocationPermission locationPermission) {
        if (locationPermission == LocationPermission.denied || locationPermission != LocationPermission.deniedForever)
          add(GeolocationErrorDetected(status: GeolocationStatus.NoPermission));
        else
          add(StartGeolocatorStream());
      });
    }
    if (event is StartGeolocatorStream) {
      print("Stream started");
      positionStream = Geolocator.getPositionStream(
              desiredAccuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 1,
              intervalDuration: Duration(seconds: 5))
          .listen((Position v) {
        lastKnownPosition = CSPosition.fromMap(v.toJson());
        add(UpdatePosition(position: lastKnownPosition));
      });
    }
    if (event is UpdatePosition) {
      print("Position updated: ${event.position.toJson()}");
      yield PositionUpdated(position: event.position);
    }
    if (event is CloseGeolocationStream) {
      positionStream.cancel();
    }
  }
}
