import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:carspace/screens/Home/MapScreen.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import '../serviceLocator.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: mainAppBar(context, 'Map', () async {
        await _authService.logOut();
        locator<NavigationService>().pushReplaceNavigateTo(LoginRoute);
      }),
      drawer: Container(
        color: Colors.red,
      ),
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        child: Stack(children: [
          MapScreen(),
        ]),
      ),
    );
  }
}
