import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleSelectorWidget.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/screens/widgets/NavigationDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';
import '../widgets/NavigationDrawer.dart';
import 'ParkNowWidget.dart';

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
        actions: [
          WalletInfoWidget(),
        ],
        leading: CSMenuButton(),
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

class CSMenuButton extends StatelessWidget {
  const CSMenuButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: Stack(children: [
        Center(
          child: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 6,
          top: 8,
          child: Icon(
            Icons.circle,
            size: 8,
            color: csStyle.csRed,
          ),
        ),
      ]),
    );
  }
}
