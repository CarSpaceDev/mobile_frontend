import 'package:android_intent/android_intent.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverNavigationService {
  DriverNavigationService();

  navigateViaMapBox(LatLng destination, String reservationId) async {
    Position currentPosition = await _determinePosition();
    print(currentPosition.toString());
    MapBoxNavigation _directions = MapBoxNavigation(onRouteEvent: routeEventHandler);
    _directions.enableOfflineRouting();
    List<WayPoint> wayPoints = List<WayPoint>();
    wayPoints.add(WayPoint(name: "Start", latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(name: "Destination", latitude: destination.latitude, longitude: destination.longitude));
    var result = await _directions.startNavigation(
        wayPoints: wayPoints,
        options: MapBoxOptions(
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
            enableRefresh: true));
    print(result);
  }

  navigateViaGoogleMaps(LatLng destination) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.navigation:q=${destination.latitude},${destination.longitude}'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  routeEventHandler(RouteEvent e) async {
    print("ROUTE EVENT HANDLER");
    switch (e.eventType) {
      case MapBoxEvent.navigation_running:
        print("Navigation has started");
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
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
