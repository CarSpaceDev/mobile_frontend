import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/screens/Home/MapScreen.dart';
import 'package:carspace/screens/login/LandingScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:carspace/screens/login/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../HomeScreen.dart';

class LoginBlocHandler extends StatefulWidget {
  @override
  _LoginBlocHandlerState createState() => _LoginBlocHandlerState();
}

class _LoginBlocHandlerState extends State<LoginBlocHandler> {
  final loginBloc = LoginBloc();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: loginBloc,
      child: BlocListener(
        bloc: loginBloc,
        listener: (BuildContext context, LoginState state) async {
          if (state is LoginInitialState) {
            var currentUser = await Provider.of<AuthService>(context, listen: false).currentUser();
            if (currentUser != null)
              loginBloc.dispatch(LoggedInEvent());
            else
              loginBloc.dispatch(NoSessionEvent());
          } else if (state is LoggedIn) {
            Provider.of<GlobalData>(context, listen: false).user = state.user;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
              ),
            );
          }
        },
        child: BlocBuilder(
            bloc: loginBloc,
            builder: (BuildContext context, LoginState state) {
              if (state is LoggedOut) {
                return LandingScreen();
              } else if (state is LoginInProgress) {
                return LoadingScreen(
                  prompt: 'Logging in',
                );
              } else if (state is AuthorizationSuccess) {
                return LoadingScreen(
                  prompt: 'Getting user data',
                );
              }
              return LoadingScreen(
                prompt: 'Checking for sessions',
              );
            }),
      ),
    );
  }
}
