import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/resusables/AppBarLayout.dart';
import 'package:carspace/screens/Home/MapScreen.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'login/LoginBlocHandler.dart';

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
      appBar: MainAppBar(context, 'Map', () async {
        await _authService.logOut();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginBlocHandler()));
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
