import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/blocs/mqtt/mqtt_bloc.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

part 'geolocation_event.dart';
part 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {
  StreamSubscription<Position> positionStream;
  CSPosition lastKnownPosition;
  bool ready = false;
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
        Position currPos = await Geolocator.getCurrentPosition();
        lastKnownPosition = CSPosition.fromMap(currPos.toJson());
        print("Geolocator is ready");
        ready = true;
        yield GeolocatorReady();
      }
    }
    if (event is StartGeolocation) {
      print("StartingGeolocationStream");
      if (ready)
        positionStream = Geolocator.getPositionStream(
                desiredAccuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 1,
                intervalDuration: Duration(seconds: 5))
            .listen((Position v) {
          lastKnownPosition = CSPosition.fromMap(v.toJson());
          add(UpdatePosition(position: lastKnownPosition));
        });
    }
    if (event is StartGeolocationBroadcast) {
      print("StartingGeolocationBroadcast");
      if (ready)
        positionStream = Geolocator.getPositionStream(
                desiredAccuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 1,
                intervalDuration: Duration(seconds: 5))
            .listen((Position p) {
          lastKnownPosition = CSPosition.fromMap(p.toJson());
          String payload = json.encode({
            "longitude": p.longitude,
            "latitude": p.latitude,
            "distance": Geolocator.distanceBetween(
                p.latitude, p.longitude, event.reservation.position.latitude, event.reservation.position.longitude)
          });
          //mqtt broadcast
          locator<NavigationService>()
              .navigatorKey
              .currentContext
              .read<MqttBloc>()
              .add(SendMessageToTopic(topic: event.reservation.uid, message: payload));
          //insert firestore session broadcast
          try {
            print("Saving position data to session FirestoreDocument");
            FirebaseFirestore.instance.collection("geo-session").doc(event.reservation.uid).set({
              "longitude": p.longitude,
              "latitude": p.latitude,
              "distance": Geolocator.distanceBetween(
                  p.latitude, p.longitude, event.reservation.position.latitude, event.reservation.position.longitude)
            });
          } catch (e) {
            print("GeolocationBloc Firestore Save Error");
            print(e);
          }
          add(UpdatePosition(position: lastKnownPosition));
        });
    }
    if (event is RequestPermission) {
      LocationPermission currentPermission = await Geolocator.requestPermission();
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
      ready = false;
      positionStream?.cancel();
      add(InitializeGeolocator());
    }
  }
}
