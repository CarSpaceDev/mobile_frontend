import 'package:carspace/blocs/vehicle/vehicle_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'VehicleScreen.dart';
import 'VehicleRegistrationScreen.dart';

class VehicleSelectorWidget extends StatefulWidget {
  @override
  _VehicleSelectorWidgetState createState() => _VehicleSelectorWidgetState();
}

class _VehicleSelectorWidgetState extends State<VehicleSelectorWidget> with TickerProviderStateMixin {
  int actualIndex = 0;
  PageController controller;
  bool noVehicles;
  String header = "";
  bool tapped = false;
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
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      child: CSTile(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.zero,
        borderRadius: 10,
        color: header.isEmpty ? TileColor.None : TileColor.Grey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (header.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.close,
                        color: Colors.transparent,
                      ),
                    ),
                  if (header.isNotEmpty)
                    Expanded(
                      child: CSText(
                        header,
                        textAlign: TextAlign.center,
                        textType: TextType.Button,
                        textColor: TextColor.Black,
                      ),
                    ),
                  if (header.isNotEmpty)
                    InkWell(
                      onTap: () {
                        setState(() {
                          header = '';
                          tapped = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.close),
                      ),
                    )
                ],
              ),
            ),
            if (!tapped)
              BlocBuilder<VehicleRepoBloc, VehicleRepoState>(builder: (BuildContext context, vehicleState) {
                if (vehicleState is VehicleRepoReady) {
                  return BlocBuilder<UserRepoBloc, UserRepoState>(builder: (BuildContext context, state) {
                    if (state is UserRepoReady) {
                      Vehicle selectedVehicle;
                      selectedVehicle = vehicleState.vehiclesCollection[state.user.currentVehicle];
                      bool vehiclesAvailable = vehicleState.vehicles.isNotEmpty;
                      // try {
                      //   selectedVehicle = vehicleState.vehicles.firstWhere((element) {
                      //     return element.plateNumber == state.user.currentVehicle;
                      //   });
                      // } catch (e) {
                      //   selectedVehicle = null;
                      //   header = "";
                      // }
                      // print(selectedVehicle?.plateNumber);
                      if (selectedVehicle == null)
                        return CurrentVehicleCard(
                            vehicle: selectedVehicle,
                            vehiclesAvailable: vehiclesAvailable,
                            onTap: () {
                              setState(() {
                                header = "${vehicleState.vehicles.first.make} ${vehicleState.vehicles.first.model}";
                                tapped = true;
                              });
                            });
                      else if (selectedVehicle?.status == VehicleStatus.Available)
                        return CurrentVehicleCard(
                            vehicle: selectedVehicle,
                            vehiclesAvailable: vehiclesAvailable,
                            onTap: () {
                              setState(() {
                                if(selectedVehicle!=null)
                                header = "${selectedVehicle.make} ${selectedVehicle.model}";
                                tapped = true;
                              });
                            });
                      else
                        return CSTile(
                          borderRadius: 16,
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          margin: EdgeInsets.zero,
                          onTap: () {
                            setState(() {
                              if(selectedVehicle!=null)
                              header = "${selectedVehicle.make} ${selectedVehicle.model}";
                              tapped = true;
                            });
                          },
                          child: CSText(
                            "${selectedVehicle.plateNumber} is unavailable for use, please choose another vehicle",
                            textAlign: TextAlign.center,
                          ),
                        );
                    }
                    return Container();
                  });
                } else
                  return Container();
              }),
            if (tapped)
              BlocBuilder<VehicleRepoBloc, VehicleRepoState>(builder: (BuildContext context, state) {
                if (state is VehicleRepoReady) {
                  return Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.6,
                        child: PageView.builder(
                            itemCount: state.vehicles.length + 1,
                            physics: BouncingScrollPhysics(),
                            controller: controller,
                            onPageChanged: (i) {
                              setState(() {
                                actualIndex = i;
                                if (i < state.vehicles.length)
                                  header = "${state.vehicles[i].make} ${state.vehicles[i].model}";
                                else
                                  header = "ADD A VEHICLE";
                              });
                            },
                            itemBuilder: (context, index) {
                              if (index < state.vehicles.length)
                                return VehicleCard(
                                  onTap: () {
                                    if (state.vehicles[index].status == VehicleStatus.Available) {
                                      locator<NavigationService>()
                                          .navigatorKey
                                          .currentContext
                                          .bloc<VehicleBloc>()
                                          .add(SetSelectedVehicle(vehicle: state.vehicles[index]));
                                      setState(() {
                                        tapped = !tapped;
                                        header = "";
                                        actualIndex = 0;
                                      });
                                    } else if (state.vehicles[index].status == VehicleStatus.Unavailable)
                                      PopUp.showError(
                                          context: context,
                                          title: "Vehicle is Unavailable",
                                          body: "This vehicle is currently unavailable");
                                    else if (state.vehicles[index].status == VehicleStatus.Unverified)
                                      PopUp.showError(
                                          context: context,
                                          title: "Vehicle is Unverified",
                                          body: "Please allow 5-15 minutes for verification or contact support");
                                    else
                                      PopUp.showError(
                                          context: context,
                                          title: "Contact Support",
                                          body: "Please email zenithdevgroup@gmail.com for details.");
                                  },
                                  vehicle: state.vehicles[index],
                                  height:
                                      index == actualIndex ? double.maxFinite : MediaQuery.of(context).size.width * 0.3,
                                );
                              else
                                return Center(child: ActionVehicleIcon());
                            }),
                      ),
                    ],
                  );
                } else
                  return Container();
              }),
            if (header != "ADD A VEHICLE" && header.isNotEmpty)
              CSText(
                "Tap to ${tapped ? "select" : "change"}",
                padding: EdgeInsets.symmetric(vertical: 16),
              )
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

class CurrentVehicleCard extends StatelessWidget {
  final Function onTap;
  final Vehicle vehicle;
  final bool vehiclesAvailable;
  CurrentVehicleCard({this.vehicle, this.onTap, this.vehiclesAvailable});
  @override
  Widget build(BuildContext context) {
    return vehicle != null
        ? VehicleListTile(
            vehicle: vehicle,
            onTap: onTap,
          )
        : InkWell(
            onTap: vehiclesAvailable ? onTap : null,
            child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ActionVehicleIcon(
                  selectVehicle: vehiclesAvailable,
                  darkMode: true,
                )),
          );
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
      child: InkWell(
        onTap: onTap,
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
                    icon: Icon(
                        vehicle.status == VehicleStatus.Available
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.xmark_circle_fill,
                        color: vehicle.status == VehicleStatus.Available
                            ? csStyle.primary
                            : vehicle.status == VehicleStatus.Blocked || vehicle.status == VehicleStatus.Rejected
                                ? csStyle.csRed
                                : csStyle.csGrey),
                    label: CSText("${Vehicle.vehicleStatus(vehicle.status)}"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActionVehicleIcon extends StatelessWidget {
  final bool selectVehicle;
  final bool darkMode;
  ActionVehicleIcon({this.selectVehicle = false, this.darkMode = false});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selectVehicle
          ? null
          : () {
              PopupNotifications.showNotificationDialog(context,
                  barrierDismissible: true,
                  child: CSTile(
                    borderRadius: 25,
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: scanQR,
                          icon: Icon(
                            Icons.qr_code,
                            color: Colors.blueAccent,
                          ),
                          label: Text('Add from code', style: TextStyle(color: Colors.blueAccent)),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            locator<NavigationService>().pushNavigateToWidget(
                              getPageRoute(
                                VehicleRegistrationScreen(
                                  fromHomeScreen: true,
                                ),
                                RouteSettings(name: "ADD-VEHICLE"),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Colors.blueAccent,
                          ),
                          label: Text('Add new vehicle', style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ));
            },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            selectVehicle ? CupertinoIcons.car_detailed : CupertinoIcons.add_circled_solid,
            size: 50,
            color: this.darkMode ? Colors.white : csStyle.primary,
          ),
          CSText(
            selectVehicle ? "Select a Vehicle" : "Add a Vehicle",
            textColor: this.darkMode ? TextColor.White : TextColor.Primary,
            textType: TextType.Button,
            textAlign: TextAlign.center,
            padding: EdgeInsets.only(top: 8),
          )
        ],
      ),
    );
  }
}
