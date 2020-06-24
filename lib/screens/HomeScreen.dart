import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';

import 'login/LoginInitialScreen.dart';


class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeData.backgroundColor,
        title: Text("End User License Agreement"),
        centerTitle: true,
        leading: IconButton( color: Colors.white,
          onPressed: () async {
            await _authService.logOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => LoginInitialScreen()));
          },
          icon: Icon(Icons.exit_to_app),
        ),
      ),
      backgroundColor: themeData.primaryColor,
      body:
      Text('Bla Bla Vla'),
    );
  }
}
