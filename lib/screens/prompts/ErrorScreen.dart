import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String prompt;
  ErrorScreen({this.prompt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 20*SizeConfig.heightMultiplier,
                child: Image.asset('assets/logo/splash_icon.png'),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(prompt, style: TextStyle(color: Colors.white),)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
