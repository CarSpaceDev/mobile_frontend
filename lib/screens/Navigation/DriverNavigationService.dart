import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/blocs/timings/timings_bloc.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class DriverNavigationService {
  MapBoxNavigation _directions;
  MapBoxOptions _mapBoxOptions;
  Reservation reservation;
  DriverNavigationService({@required this.reservation}) {
    _directions = MapBoxNavigation(onRouteEvent: routeEventHandler);
  }

  navigateViaMapBox() async {
    locator<NavigationService>()
        .navigatorKey
        .currentContext
        .read<TimingsBloc>()
        .add(StartTest(type: TimingsType.Navigation));
    Position currentPosition = await Geolocator.getCurrentPosition();
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
    wayPoints.add(WayPoint(
        name: "Destination", latitude: reservation.position.latitude, longitude: reservation.position.longitude));
    var result = await _directions.startNavigation(wayPoints: wayPoints, options: _mapBoxOptions);
  }

  routeEventHandler(RouteEvent e) async {
    print(e.eventType);
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    switch (e.eventType) {
      case MapBoxEvent.navigation_running:
        print("Navigation has started");
        break;
      case MapBoxEvent.milestone_event:
        locator<NavigationService>()
            .navigatorKey
            .currentContext
            .read<TimingsBloc>()
            .add(EndTest(type: TimingsType.Navigation));
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        locator<NavigationService>().navigatorKey.currentContext.read<GeolocationBloc>().add(CloseGeolocationStream());
        print("Navigation has ended");
        break;
      default:
        break;
    }
  }
}
