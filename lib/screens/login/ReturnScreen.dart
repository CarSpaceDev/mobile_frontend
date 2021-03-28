import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/login/login_bloc.dart';

class ReturnScreen extends StatefulWidget {
  @override
  _ReturnScreen createState() => _ReturnScreen();
}

class _ReturnScreen extends State<ReturnScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: csTheme.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Register Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo/CarSpace.png',
                      height: 115,
                      width: 115,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              SizedBox(height: 22.0),
              Text(
                "Email already registered....",
                style: TextStyle(fontFamily: "Champagne & Limousines", fontWeight: FontWeight.bold, fontSize: 30.0, color: Colors.white),
              ),
              SizedBox(height: 22.0),
              _nextButton(),
              SizedBox(height: 5.0),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(225.0, 0, 0, 0),
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          navigateToRegisterEvent(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  navigateToRegisterEvent(BuildContext context) {
    context.bloc<LoginBloc>().add(NavigateToRegisterEvent());
  }
}
