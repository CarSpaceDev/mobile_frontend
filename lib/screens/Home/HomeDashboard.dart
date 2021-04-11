import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/Home/Popup.dart';
import 'package:carspace/screens/Home/WalletInfoWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';

class HomeDashboard extends StatefulWidget {
  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  CSUser userData;

  @override
  void initState() {
    _initAccess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: CSText("Dashboard", textType: TextType.H4, textColor: TextColor.White),
      ),
      drawer: homeNavigationDrawer(context),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login_screen_assets/bg.png"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
                ),
              ),
            ),
            CSTile(
              margin: EdgeInsets.zero,
              color: TileColor.None,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CSTile(
                      borderRadius: 8,
                      child: CSText("Current Reservation ETC"),
                    ),
                    WalletInfoWidget(),
                    CSTile(
                      borderRadius: 8,
                      child: CSText("Current Selected Vehicle"),
                    ),
                    ParkNowWidget()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _initAccess() async {
    bool result;
    await locator<ApiService>().getUserData(uid: locator<AuthService>().currentUser().uid).then((data) {
      if (data.statusCode == 200) {
        userData = CSUser.fromJson(data.body);
        print(userData.toJson());
        result = true;
      } else
        result = false;
    });
    return result;
  }

  Drawer homeNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (userData == null)
            Container(
              child: Center(
                child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      Text(
                        "Loading",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      )
                    ],
                  ),
                ),
              ),
            )
          else
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.profile_circled,
                    size: 60,
                  ),
                  CSText(
                    locator<AuthService>().currentUser().displayName,
                    textType: TextType.H4,
                    padding: EdgeInsets.only(top: 16),
                  )
                ],
              ),
            ),
          ListTile(
            title: InkWell(
                onTap: () {
                  locator<NavigationService>().pushNavigateTo(WalletRoute);
                },
                child: Text("Wallet")),
          ),
          ListTile(
            title: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Popup.showNotificationDialog(context);
                },
                child: Text("Notifications")),
          ),
          ListTile(
            title: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  locator<NavigationService>().pushNavigateTo(VehicleManagement);
                },
                child: Text("Vehicles")),
          ),
          ListTile(
            title: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  locator<NavigationService>().pushNavigateTo(Reservations);
                },
                child: Text("Reservations")),
          ),
          ListTile(
            title: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  locator<NavigationService>().pushNavigateTo(HomeDashboardRoute);
                },
                child: Text("Dashboard WIP")),
          ),
          if (userData != null)
            if (userData.partnerAccess > 200)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateTo(PartnerReservations);
                    },
                    child: Text("Partner Reservations")),
              ),
          ListTile(
            title: InkWell(
                onTap: () {
                  locator<NavigationService>().pushReplaceNavigateTo(LoginRoute);
                  context.read<LoginBloc>().add(LogoutEvent());
                },
                child: Text("Sign Out")),
          ),
        ],
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
                            border: Border(left: BorderSide(width: 1, color: csStyle.csWhite), right: BorderSide(width: 1, color: csStyle.csWhite))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.time,
                              color: csStyle.csWhite,
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
                              CupertinoIcons.car_detailed,
                              color: csStyle.csWhite,
                            ),
                            CSText(
                              "DRIVE TO DESTINATION",
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
