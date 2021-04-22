import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/Home/VehicleSelectorWidget.dart';
import 'package:carspace/screens/Home/WalletInfoWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../serviceLocator.dart';
import '../Widgets/NavigationDrawer.dart';

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
                ParkNowWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ParkNowWidget extends StatefulWidget {
  @override
  _ParkNowWidgetState createState() => _ParkNowWidgetState();
}

class _ParkNowWidgetState extends State<ParkNowWidget> {
  PageController _pageController = new PageController();
  @override
  Widget build(BuildContext context) {
    return CSTile(
      padding: EdgeInsets.zero,
      shadow: true,
      showBorder: false,
      color: TileColor.None,
      child: Container(
        height: 160,
        decoration: BoxDecoration(color: csStyle.primary, borderRadius: BorderRadius.all(Radius.circular(8))),
        child: PageView(
          controller: _pageController,
          physics: new NeverScrollableScrollPhysics(),
          children: [
            //page 1
            InkWell(
              onTap: () {
                _pageController.animateToPage(1, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
              },
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
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.car_detailed,
                              color: csStyle.csWhite,
                              size: 50,
                            ),
                            CSText("DRIVE\n(ON DEMAND)", textColor: TextColor.White, textAlign: TextAlign.center)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(width: 1, color: csStyle.csWhite),
                                right: BorderSide(width: 1, color: csStyle.csWhite))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.time,
                              color: csStyle.csWhite,
                              size: 50,
                            ),
                            CSText(
                              "RESERVE A PARKING SLOT",
                              textColor: TextColor.White,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.map_pin_ellipse,
                              color: csStyle.csWhite,
                              size: 50,
                            ),
                            CSText(
                              "PARK AT DESTINATION",
                              textColor: TextColor.White,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
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
