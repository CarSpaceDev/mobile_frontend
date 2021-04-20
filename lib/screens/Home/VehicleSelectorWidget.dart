import 'package:carspace/blocs/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/blocs/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../serviceLocator.dart';

class VehicleSelectorWidget extends StatefulWidget {
  @override
  _VehicleSelectorWidgetState createState() => _VehicleSelectorWidgetState();
}

class _VehicleSelectorWidgetState extends State<VehicleSelectorWidget> with TickerProviderStateMixin {
  VehicleRepoBloc vehicleRepoBloc;
  UserRepoBloc userRepoBloc;
  int actualIndex = 0;
  PageController controller;
  bool noVehicles;
  String header = "Vehicle Selected";
  bool tapped = true;

  @override
  void initState() {
    controller = PageController(initialPage: actualIndex, viewportFraction: 1 / 2);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleRepoBloc == null) {
      vehicleRepoBloc = VehicleRepoBloc();
      vehicleRepoBloc.add(InitializeVehicleRepo(uid: locator<AuthService>().currentUser().uid));
      // vehicleBloc.add(InitializeVehicleRepo(uid:null));
    }
    if (userRepoBloc == null) {
      userRepoBloc = UserRepoBloc();
      userRepoBloc.add(InitializeUserRepo(uid: locator<AuthService>().currentUser().uid));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => vehicleRepoBloc,
        ),
        BlocProvider(
          create: (BuildContext context) => userRepoBloc,
        ),
      ],
      child: AnimatedSize(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 200),
        child: CSTile(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 16),
          borderRadius: 10,
          color: TileColor.Grey,
          child: Column(
            children: [
              CSText(
                header,
                textAlign: TextAlign.center,
                textType: TextType.H3Bold,
                textColor: TextColor.Black,
                padding: EdgeInsets.only(bottom: 8),
              ),
              BlocBuilder<VehicleRepoBloc, VehicleRepoState>(builder: (BuildContext context, state) {
                if (state is VehicleRepoReady) {
                  return AspectRatio(
                    aspectRatio: 1.6,
                    child: PageView.builder(
                        itemCount: state.vehicles.length + 1,
                        physics: BouncingScrollPhysics(),
                        controller: controller,
                        onPageChanged: (i) {
                          setState(() {
                            actualIndex = i;
                            if (i < state.vehicles.length) header = "${state.vehicles[i].make} ${state.vehicles[i].model}";
                            else header = "ADD A VEHICLE";
                          });
                        },
                        itemBuilder: (context, index) {
                          if (index < state.vehicles.length)
                            return VehicleCard(
                              onTap: () {
                                print("${state.vehicles[index].make} ${state.vehicles[index].model} SELECTED");
                              },
                              vehicle: state.vehicles[index],
                              height: index == actualIndex ? double.maxFinite : MediaQuery.of(context).size.width * 0.3,
                            );
                          else
                            return IconButton(
                              onPressed: () {},
                              icon: Icon(
                                CupertinoIcons.add_circled_solid,
                                size: 50,
                                color: csStyle.primary,
                              ),
                            );
                        }),
                  );
                } else
                  return Container();
              }),
              CSText("Tap to select", padding: EdgeInsets.only(top:16),)
            ],
          ),
        ),
      ),
    );
  }

  calculatePage(int v, List<dynamic> vehicles, {bool previous = true}) {
    if (previous) {
      if (v == 0) return vehicles.length - 1;
      return v - 1;
    } else {
      if (v == vehicles.length - 1) return 0;
      return v + 1;
    }
  }
}

class VehicleCard extends StatelessWidget {
  final double height;
  final Function onTap;
  final Vehicle vehicle;
  VehicleCard({
    @required this.vehicle,
    this.onTap,
    @required this.height,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: height,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CSText(
                "${vehicle.plateNumber}",
                textAlign: TextAlign.center,
                padding: EdgeInsets.all(12),
                textType: TextType.Button,
                textColor: TextColor.Black,
              ),
              Flexible(
                child: Center(
                  child: Image.network(
                    vehicle.vehicleImage,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              TextButton.icon(
                  onPressed: null,
                  icon: Icon(CupertinoIcons.check_mark_circled_solid,
                      color: vehicle.isVerified ? csStyle.primary : csStyle.csGrey),
                  label: CSText(vehicle.isVerified ? "AVAILABLE" : "UNVERIFIED"))
            ],
          ),
        ),
      ),
    );
  }
}
