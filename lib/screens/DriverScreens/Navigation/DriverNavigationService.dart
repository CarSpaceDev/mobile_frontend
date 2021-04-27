import 'dart:async';
import 'dart:convert';

import 'package:carspace/services/MqttService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverNavigationService {
  MapBoxNavigation _directions;
  MapBoxOptions _mapBoxOptions;
  StreamSubscription<Position> _positionStream;
  String reservationId;
  DriverNavigationService({@required this.reservationId}) {
    _directions = MapBoxNavigation(onRouteEvent: routeEventHandler);
    _directions.enableOfflineRouting();
  }

  navigateViaMapBox(LatLng destination) async {
    Position currentPosition = await _determinePosition();
    _sendStartNavigationMessage(currentPosition);
    _mapBoxOptions = _mapBoxOptions = MapBoxOptions(
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        longPressDestinationEnabled: false,
        mode: MapBoxNavigationMode.driving,
        simulateRoute: false,
        tilt: 0.0,
        bearing: 0.0,
        language: "en",
        units: VoiceUnits.metric,
        zoom: 23,
        animateBuildRoute: true,
        initialLatitude: currentPosition.latitude,
        initialLongitude: currentPosition.longitude,
        enableRefresh: true);
    List<WayPoint> wayPoints = [];
    wayPoints.add(WayPoint(name: "Start", latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(name: "Destination", latitude: destination.latitude, longitude: destination.longitude));
    var result = await _directions.startNavigation(wayPoints: wayPoints, options: _mapBoxOptions);
  }

  _openPositionStream() {
    _positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
            intervalDuration: Duration(seconds: 5))
        .listen(_positionChangeHandler);
  }

  _closePositionStream() {
    if (_positionStream != null) {
      _positionStream.cancel();
      _sendEndNavigationMessage();
    }
  }

  _positionChangeHandler(Position p) async {
    String payload = json.encode({
      "reservationId": this.reservationId,
      "longitude": p.longitude,
      "latitude": p.latitude,
    });
    locator<MqttService>().send(this.reservationId, payload);
  }

  _sendEndNavigationMessage() {
    String payload = json.encode({"reservationId": this.reservationId, "message": "Navigation Ended"});

    locator<MqttService>().send(this.reservationId, payload);
  }

  _sendStartNavigationMessage(Position p) {
    String payload = json.encode({
      "reservationId": this.reservationId,
      "message": "Navigation Starting",
      "longitude": p.longitude,
      "latitude": p.latitude,
    });
    locator<MqttService>().send(this.reservationId, payload);
  }

  routeEventHandler(RouteEvent e) async {
    print("ROUTE EVENT HANDLER");
    print(e.eventType);
    switch (e.eventType) {
      case MapBoxEvent.navigation_running:
        print("Navigation has started");
        _openPositionStream();
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _closePositionStream();
        print("Navigation has ended");
        break;
      default:
        break;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error('Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
