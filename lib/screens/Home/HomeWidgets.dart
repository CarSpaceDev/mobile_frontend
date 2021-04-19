import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/blocs/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../navigation.dart';
import '../../serviceLocator.dart';
import 'Popup.dart';

class HomeNavigationDrawer extends StatefulWidget {
  @override
  _HomeNavigationDrawerState createState() => _HomeNavigationDrawerState();
}

class _HomeNavigationDrawerState extends State<HomeNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:
      BlocBuilder<UserRepoBloc, UserRepoState>(builder: (context, state) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            if (state is UserRepoReady)
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.profile_circled,
                      size: 60,
                    ),
                    CSText(
                      state.user.displayName,
                      textType: TextType.H4,
                      padding: EdgeInsets.only(top: 16),
                    )
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
                          backgroundColor: Theme
                              .of(context)
                              .primaryColor,
                        ),
                        Text(
                          "Loading",
                          style: TextStyle(color: Theme
                              .of(context)
                              .primaryColor),
                        )
                      ],
                    ),
                  ),
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
            if (state is UserRepoReady && state.user.partnerAccess > 200)
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
        );

      }),
    );
  }
}



class BackgroundImage extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  BackgroundImage({this.child, this.padding = EdgeInsets.zero});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login_screen_assets/bg.png"),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
        ),
      ),
      child: child,
    );
  }
}
