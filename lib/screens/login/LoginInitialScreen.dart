import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/screens/login/EulaScreen.dart';
import 'package:carspace/screens/login/LandingScreen.dart';
import 'package:flutter/material.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/screens/login/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:carspace/screens/login/RegistrationScreen.dart';
import '../HomeScreen.dart';

class LoginInitialScreen extends StatefulWidget {
  @override
  _LoginInitialScreenState createState() => _LoginInitialScreenState();
}

class _LoginInitialScreenState extends State<LoginInitialScreen> {
  final loginBloc = LoginBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: loginBloc,
      child: BlocListener(
        bloc: loginBloc,
        listener: (BuildContext context, LoginState state) {

          if (state is NavToRegister)
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => RegistrationScreen()));
        },
        child: BlocBuilder(
            bloc: loginBloc,
            builder: (BuildContext context, LoginState state) {
              if (state is InitialLoginState) return LandingScreen();
              return LandingScreen();
            }),
      ),
    );
  }




}

