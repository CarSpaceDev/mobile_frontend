import 'dart:ui';

import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/Dashboard/HomeDashboard.dart';
import 'package:carspace/screens/Dashboard/PartnerDashboard.dart';
import 'package:carspace/screens/Lots/LotsScreen.dart';
import 'package:carspace/screens/Notifications/NotificationList.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class HomeNavigationDrawer extends StatefulWidget {
  final bool isPartner;
  HomeNavigationDrawer({this.isPartner = false});
  @override
  _HomeNavigationDrawerState createState() => _HomeNavigationDrawerState();
}

class _HomeNavigationDrawerState extends State<HomeNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<UserRepoBloc, UserRepoState>(builder: (context, state) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (state is UserRepoReady)
              CSTile(
                linePaddingLeft: 0,
                linePaddingRight: 0,
                solidDivider: true,
                padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CSTile(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.only(bottom: 16),
                      linePaddingLeft: 0,
                      linePaddingRight: 0,
                      solidDivider: true,
                      child: Column(
                        children: [
                          Icon(
                            widget.isPartner ? FontAwesomeIcons.parking:CupertinoIcons.car_detailed ,
                            size: 45,
                            color: Theme.of(context).primaryColor
                          ),
                          CSText(
                            state.user.displayName,
                            textType: TextType.H4,
                            padding: EdgeInsets.only(top: 16, bottom: 16),
                          ),
                          if(state.user.rating!=null) SmoothStarRating(
                            rating: state.user.rating,
                            isReadOnly: true,
                            size: 32,
                            filledIconData: Icons.star,
                            halfFilledIconData: Icons.star_half,
                            defaultIconData: Icons.star_border,
                            starCount: 5,
                            allowHalfRating: true,
                            spacing: 2.0,
                            onRated: null,
                          )
                        ],
                      ),
                    ),
                    WalletInfoWidget(
                      textColor: TextColor.Black,
                    ),
                  ],
                ),
              ),
            if (!(state is UserRepoReady))
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
              ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    PopupNotifications.showNotificationDialog(context, child: NotificationList());
                  },
                  child: Text("Notifications")),
            ),
            if (!widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateTo(VehicleManagement);
                    },
                    child: Text("Vehicles")),
              ),
            if (!widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateTo(Reservations);
                    },
                    child: Text("Reservations")),
              ),
            if (state is UserRepoReady && state.user.partnerAccess > 200 && widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateTo(PartnerReservations);
                    },
                    child: Text("Your Lot Reservations")),
              ),
            if (widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);

                      locator<NavigationService>().navigatorKey.currentContext.read<GeolocationBloc>().add(InitializeGeolocator());
                      locator<NavigationService>().pushNavigateToWidget(
                        getPageRoute(
                          LotsScreen(),
                          RouteSettings(name: "LOTS"),
                        ),
                      );
                    },
                    child: Text("Your Lots")),
              ),
            if (widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateToWidget(
                        getPageRoute(
                          HomeDashboard(),
                          RouteSettings(name: "DRIVER DASHBOARD"),
                        ),
                      );
                    },
                    child: Text("Switch to Driver")),
              ),
            if (state is UserRepoReady && state.user.partnerAccess > 200 && !widget.isPartner)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateToWidget(
                        getPageRoute(
                          PartnerDashboard(),
                          RouteSettings(name: "PARTNER DASHBOARD"),
                        ),
                      );
                    },
                    child: Text("Switch to Partner")),
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
        );
      }),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final AssetBundleImageProvider background;
  final double blur;
  final double opacity;
  BackgroundImage(
      {this.child,
      this.padding = EdgeInsets.zero,
      this.blur = 0.0,
      this.opacity = 0.6,
      this.background = const AssetImage("assets/login_screen_assets/bg.png")});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: background,
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(opacity), BlendMode.dstATop),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10 * blur, sigmaY: 10 * blur),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: padding,
          alignment: Alignment.center,
          color: Colors.grey.withOpacity(0.1),
          child: child,
        ),
      ),
    );
  }
}
