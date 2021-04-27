import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String prompt;
  LoadingScreen({this.prompt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 20 * SizeConfig.heightMultiplier,
                child: Image.asset('assets/logo/splash_icon.png'),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
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
                        prompt,
                        style: TextStyle(color: Colors.white),
                      )
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
