import 'package:carspace/blocs/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/blocs/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/reusable/CSText.dart';
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
  VehicleRepoBloc vehicleBloc;
  UserRepoBloc userBloc;
  int actualIndex = 0;
  PageController controller;
  bool noVehicles;

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
    if (vehicleBloc == null) {
      vehicleBloc = VehicleRepoBloc();
      vehicleBloc.add(InitializeVehicleRepo(uid: locator<AuthService>().currentUser().uid));
    }
    if (userBloc == null) {
      userBloc = UserRepoBloc();
      userBloc.add(InitializeUserRepo(uid: locator<AuthService>().currentUser().uid));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) => vehicleBloc,
        ),
        BlocProvider(
          create: (BuildContext context) => userBloc,
        ),
      ],
      child: AnimatedSize(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 200),
        child: Column(
          children: [
            CSText(
              "VEHICLE SELECTED",
              textAlign: TextAlign.center,
              textType: TextType.H5Bold,
              textColor: TextColor.White,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            BlocBuilder<VehicleRepoBloc, VehicleRepoState>(builder: (BuildContext context, state) {
              if (state is VehicleRepoReady) {
                return Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.4,
                      child: PageView.builder(
                          itemCount: state.vehicles.length,
                          physics: BouncingScrollPhysics(),
                          controller: controller,
                          onPageChanged: (i) {
                            setState(() {
                              actualIndex = i;
                            });
                            print(actualIndex);
                          },
                          itemBuilder: (context, index) {
                            return VehicleImage(
                                onTap: () {
                                  if (actualIndex < index) {
                                    controller.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                  }
                                  if (actualIndex > index) {
                                    controller.previousPage(
                                        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                                  }
                                },
                                vehicle: state.vehicles[index],
                                height: index == actualIndex
                                    ? MediaQuery.of(context).size.width * 0.4
                                    : MediaQuery.of(context).size.width * 0.25,
                                width: index == actualIndex
                                    ? MediaQuery.of(context).size.width * 0.8
                                    : MediaQuery.of(context).size.width * 0.25);
                          }),
                    ),
                  ],
                );
              } else
                return Container();
            }),
          ],
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

class VehicleImage extends StatelessWidget {
  final double height;
  final double width;
  final Function onTap;
  final Vehicle vehicle;
  VehicleImage({@required this.vehicle, this.onTap, @required this.height, @required this.width});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: height,
        width: width,
        margin: EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CSText(
                    "${vehicle.make} ${vehicle.model}",
                    textAlign: TextAlign.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  Flexible(
                    child: Center(
                      child: Image.network(
                        vehicle.vehicleImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  CSText(
                    "${vehicle.plateNumber}",
                    textAlign: TextAlign.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
