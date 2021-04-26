import 'package:carspace/screens/DriverScreens/TransactionModes/DriveModeScreen.dart';
import 'package:carspace/screens/DriverScreens/HomeDashboard.dart';
import 'package:carspace/screens/Home/PartnerReservationScreen.dart';
import 'package:carspace/screens/Home/ReservationScreen.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleManagementScreen.dart';
import 'package:carspace/screens/Login/LoginBlocHandler.dart';
import 'package:carspace/screens/Wallet/WalletScreen.dart';
import 'package:carspace/screens/Initialization/InitializationBlocHandler.dart';
import 'package:flutter/material.dart';

const String LoginRoute = '/login';
const String InitializationRoute = '/init';
const String FilterRoute = '/filter';
const String SettingsRoute = '/settings';
const String NotificationsRoute = '/notifications';
const String VehicleManagement = '/vehicle-manage';
const String Reservations = '/user-reservations';
const String DashboardRoute = '/home';
const String PartnerReservations = '/partner-reservations';
const String WalletRoute = '/wallet';
const String DriveModeRoute = '/drive';
// ignore: missing_return
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case InitializationRoute:
      return getPageRoute(InitializationScreen(), settings);
    case LoginRoute:
      return getPageRoute(LoginBlocHandler(), settings);
    case DashboardRoute:
      return getPageRoute(HomeDashboard(), settings);
    case VehicleManagement:
      return getPageRoute(VehicleManagementScreen(), settings);
    case Reservations:
      return getPageRoute(ReservationScreen(), settings);
    case PartnerReservations:
      return getPageRoute(PartnerReservationScreen(), settings);
    case WalletRoute:
      return getPageRoute(WalletScreen(), settings);
    case DriveModeRoute:
      return getPageRoute(DriveModeScreen(), settings);
  }
}

PageRoute getPageRoute(Widget child, RouteSettings settings) {
  return FadeRoute(child: child, routeName: settings.name);
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNavigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> pushReplaceNavigateTo(String routeName) {
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }

  Future<dynamic> pushNavigateToWidget(Route<dynamic> route) {
    return navigatorKey.currentState.push(route);
  }

  Future<dynamic> pushReplaceNavigateToWidget(Route<dynamic> route) {
    return navigatorKey.currentState.pushReplacement(route);
  }

  goBack() {
    return navigatorKey.currentState.pop();
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;
  FadeRoute({this.child, this.routeName})
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
