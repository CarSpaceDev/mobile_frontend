import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/blocs/vehicle/vehicle_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/screens/DriverScreens/DestinationPicker.dart';
import 'package:carspace/screens/Home/VehicleSelectorWidget.dart';
import 'package:carspace/screens/Home/WalletInfoWidget.dart';
import 'package:carspace/screens/repository/submitRepo.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';
import '../Widgets/NavigationDrawer.dart';
import 'TransactionModes/DriveModeScreen.dart';

class HomeDashboard extends StatefulWidget {
  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    locator<NavigationService>().navigatorKey.currentContext.read<GeolocationBloc>().add(InitializeGeolocator());
    super.initState();
  }

  @override
  void dispose() {
    locator<NavigationService>().navigatorKey.currentContext.read<GeolocationBloc>().add(CloseGeolocationStream());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: CSText("Dashboard", textType: TextType.H4, textColor: TextColor.White),
        actions: [WalletInfoWidget()],
      ),
      drawer: HomeNavigationDrawer(),
      body: SafeArea(
        child: BackgroundImage(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CSTile(
                  borderRadius: 8,
                  child: CSText("Current Reservation ETC"),
                  margin: EdgeInsets.symmetric(vertical: 8),
                ),
                VehicleSelectorWidget(),
                BlocBuilder<UserRepoBloc, UserRepoState>(builder: (BuildContext context, UserRepoState userState) {
                  if (userState is UserRepoReady && userState.user.currentVehicle != null)
                    return BlocBuilder<VehicleRepoBloc, VehicleRepoState>(
                        builder: (BuildContext context, VehicleRepoState vehicleState) {
                      if (vehicleState is VehicleRepoReady) {
                        return BlocBuilder<GeolocationBloc, GeolocationState>(
                            builder: (BuildContext context, GeolocationState state) {
                          Vehicle vehicle;
                          try {
                            vehicle =
                                vehicleState.vehicles.firstWhere((v) => v.plateNumber == userState.user.currentVehicle);
                          } catch (e) {}
                          if (state is GeolocatorReady &&
                              vehicle != null &&
                              vehicle?.status == VehicleStatus.Available) {
                            return ParkNowWidget(
                              enabled: true,
                              selectedVehicle: vehicle,
                            );
                          } else
                            return ParkNowWidget(
                              enabled: false,
                            );
                        });
                      } else
                        return ParkNowWidget(
                          enabled: false,
                        );
                    });
                  else
                    return ParkNowWidget(
                      enabled: false,
                    );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParkNowWidget extends StatefulWidget {
  final Vehicle selectedVehicle;
  final bool enabled;
  ParkNowWidget({this.enabled = false, this.selectedVehicle});
  @override
  _ParkNowWidgetState createState() => _ParkNowWidgetState();
}

class _ParkNowWidgetState extends State<ParkNowWidget> {
  PageController _pageController = new PageController();
  NavigationService nav = locator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    return CSTile(
      padding: EdgeInsets.zero,
      shadow: true,
      showBorder: false,
      color: TileColor.None,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
            color: widget.enabled ? csStyle.primary : csStyle.csGrey,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: PageView(
          controller: _pageController,
          physics: new NeverScrollableScrollPhysics(),
          children: [
            //page 1
            InkWell(
              onTap: widget.enabled
                  ? () {
                      _pageController.animateToPage(1, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                    }
                  : null,
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CSText(
                        "PARK NOW",
                        textColor: TextColor.White,
                        textAlign: TextAlign.center,
                        textType: TextType.H2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //page 2
            Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DriverOptions(
                    icon: Icon(
                      CupertinoIcons.car_detailed,
                      color: csStyle.csWhite,
                      size: 50,
                    ),
                    label: "DRIVE\n(ON DEMAND)",
                    onTap: () {
                      context.read<GeolocationBloc>().add(StartGeolocation());
                      nav.pushNavigateToWidget(FadeRoute(child: DriveModeScreen(), routeName: "TransactionDriveMode"));
                      _pageController.jumpToPage(0);
                    },
                  ),
                  DriverOptions(
                    icon: Icon(
                      CupertinoIcons.time,
                      color: csStyle.csWhite,
                      size: 50,
                    ),
                    label: "RESERVE A PARKING SLOT",
                    borderEnabled: true,
                    onTap: () {
                      if (widget.selectedVehicle.ownerId == locator<AuthService>().currentUser().uid) {
                        context.read<GeolocationBloc>().add(StartGeolocation());
                        nav.pushNavigateToWidget(FadeRoute(
                            child: DestinationPicker(
                              mode: ParkingType.Reservation,
                            ),
                            routeName: "ReserveParking"));
                        _pageController.jumpToPage(0);
                      } else
                        PopUp.showError(
                            context: context,
                            title: "UNAVAILABLE",
                            body: "Reservation mode is only available to the owner of the vehicle.");
                    },
                  ),
                  DriverOptions(
                    icon: Icon(
                      CupertinoIcons.map_pin_ellipse,
                      color: csStyle.csWhite,
                      size: 50,
                    ),
                    label: "PARK AT DESTINATION",
                    onTap: () async {
                      nav.pushNavigateToWidget(FadeRoute(
                          child: DestinationPicker(
                            mode: ParkingType.Booking,
                          ),
                          routeName: "ReserveParking"));
                      _pageController.jumpToPage(0);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DriverOptions extends StatelessWidget {
  final bool borderEnabled;
  final Icon icon;
  final String label;
  final Function onTap;
  DriverOptions({@required this.icon, @required this.label, this.borderEnabled = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: borderEnabled
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 1, color: csStyle.csWhite),
                    right: BorderSide(width: 1, color: csStyle.csWhite),
                  ),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 0, width: 0),
              icon,
              CSText(
                label,
                textColor: TextColor.White,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
