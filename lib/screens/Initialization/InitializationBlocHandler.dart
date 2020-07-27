import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/screens/login/LoginBlocHandler.dart';
import 'package:carspace/screens/prompts/ErrorScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/DevTools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'initialization_bloc.dart';

class InitializationBlocHandler extends StatefulWidget {
  @override
  _InitializationBlocHandlerState createState() =>
      _InitializationBlocHandlerState();
}

class _InitializationBlocHandlerState extends State<InitializationBlocHandler> {
  @override
  Widget build(BuildContext context) {
    var globalData = Provider.of<GlobalData>(context, listen: false);
    var apiService = Provider.of<ApiService>(context, listen: false);
    return BlocProvider(
      create: (BuildContext context) => InitializationBloc(),
      child: BlocConsumer<InitializationBloc, InitializationState>(
          listener: (context, state) async {
        //listener is only called once for each state change
        // (NOT including the initial state) unlike builder in BlocBuilder and is a void function.
        if (state is BeginInitState) {
          devLog("InitialState", "InitialState Check");
          var result = await apiService.requestInitData();
          if (result.statusCode == 200) {
            globalData.eula = result.body['eula'];
            devLog("EULA", globalData.eula);
            context.bloc<InitializationBloc>().add(ReadyEvent());
          } else {
            devLog(
                "InitError",
                'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                    result.statusCode.toString());
            context.bloc<InitializationBloc>().add(ErrorEvent());
          }
        }
      }, builder: (context, state) {
        if (state is InitialState) {
          context.bloc<InitializationBloc>().add(BeginInitEvent());
          return LoadingScreen(
            prompt: 'Starting Initialization',
          );
        } else if (state is ReadyState)
          return LoginBlocHandler();
        else if (state is ErrorState)
          return ErrorScreen(
            prompt:
                'There has been an error in getting needed resources.\n Please try again later.',
          );
        return LoadingScreen(
          prompt: 'Getting latest resources',
        );
      }),
    );
  }
}
