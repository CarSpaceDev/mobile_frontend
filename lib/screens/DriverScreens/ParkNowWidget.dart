import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation.dart';
import '../../serviceLocator.dart';
import 'DestinationPicker.dart';
import 'TransactionModes/DriveModeScreen.dart';

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
                      size: 45,
                    ),
                    label: "DRIVE\n(ON DEMAND)",
                    onTap: widget.enabled
                        ? () {
                            context.read<GeolocationBloc>().add(StartGeolocation());
                            nav.pushNavigateToWidget(
                                FadeRoute(child: DriveModeScreen(), routeName: "TransactionDriveMode"));
                            _pageController.jumpToPage(0);
                          }
                        : () {
                            _pageController.animateToPage(0,
                                duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                          },
                  ),
                  DriverOptions(
                    icon: Icon(
                      CupertinoIcons.time,
                      color: csStyle.csWhite,
                      size: 45,
                    ),
                    label: "RESERVE A PARKING SLOT",
                    borderEnabled: true,
                    onTap: widget.enabled
                        ? () {
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
                          }
                        : () {
                            _pageController.animateToPage(0,
                                duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                          },
                  ),
                  DriverOptions(
                    icon: Icon(
                      CupertinoIcons.map_pin_ellipse,
                      color: csStyle.csWhite,
                      size: 45,
                    ),
                    label: "PARK AT DESTINATION",
                    onTap: widget.enabled
                        ? () {
                            nav.pushNavigateToWidget(FadeRoute(
                                child: DestinationPicker(
                                  mode: ParkingType.Booking,
                                ),
                                routeName: "ReserveParking"));
                            _pageController.jumpToPage(0);
                          }
                        : () {
                            _pageController.animateToPage(0,
                                duration: Duration(milliseconds: 100), curve: Curves.easeIn);
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
                textType: TextType.Caption,
              )
            ],
          ),
        ),
      ),
    );
  }
}
