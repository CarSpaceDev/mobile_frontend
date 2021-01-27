import 'package:carspace/screens/Home/HomeScreen.dart';
import 'package:carspace/screens/Home/PartnerReservationScreen.dart';
import 'package:carspace/screens/Home/ReservationScreen.dart';
import 'package:carspace/screens/Home/VehicleManagementScreen.dart';
import 'package:carspace/screens/Initialization/InitializationBlocHandler.dart';
import 'package:carspace/screens/Navigation/NavigationScreenDriver.dart';
import 'package:carspace/screens/Navigation/NavigationScreenPartner.dart';
import 'package:carspace/screens/login/LoginBlocHandler.dart';
import 'package:flutter/material.dart';

const String LoginRoute = '/login';
const String InitializationRoute = '/init';
const String FilterRoute = '/filter';
const String SettingsRoute = '/settings';
const String NotificationsRoute = '/notifications';
const String VehicleManagement = '/vehicle-manage';
const String Reservations = '/user-reservations';
const String HomeRoute = '/home';
const String PartnerReservations = '/partner-reservations';
const String BetaFunctions = '/beta';
const String BetaFunctions2 = '/beta2';
// ignore: missing_return
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case InitializationRoute:
      return _getPageRoute(InitializationBlocHandler(), settings);
    case LoginRoute:
      return _getPageRoute(LoginBlocHandler(), settings);
    case HomeRoute:
      return _getPageRoute(HomeScreen(), settings);
    case VehicleManagement:
      return _getPageRoute(VehicleManagementScreen(), settings);
    case Reservations:
      return _getPageRoute(ReservationScreen(), settings);
    case PartnerReservations:
      return _getPageRoute(PartnerReservationScreen(), settings);
    case BetaFunctions:
      return _getPageRoute(NavigationScreenPartner(), settings);
    case BetaFunctions2:
      return _getPageRoute(NavigationScreenDriver(), settings);
  }
}

PageRoute _getPageRoute(Widget child, RouteSettings settings) {
  return _FadeRoute(child: child, routeName: settings.name);
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNavigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> pushReplaceNavigateTo(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  goBack() {
    return navigatorKey.currentState.pop();
  }
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;
  _FadeRoute({this.child, this.routeName})
      : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
