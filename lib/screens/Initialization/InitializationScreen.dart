import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/screens/login/LoginBlocHandler.dart';
import 'package:carspace/screens/prompts/ErrorScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc.dart';

class InitializationBlocHandler extends StatefulWidget {
  @override
  _InitializationBlocHandlerState createState() => _InitializationBlocHandlerState();
}

class _InitializationBlocHandlerState extends State<InitializationBlocHandler> {
  final initBloc = InitializationBloc();

  @override
  Widget build(BuildContext context) {
    var globalData = Provider.of<GlobalData>(context, listen: false);
    var apiService = Provider.of<ApiService>(context, listen: false);
    return BlocProvider(
      bloc: initBloc,
      child: BlocListener(
        bloc: initBloc,
        listener: (BuildContext context, InitializationState state) async {
          if (state is InitialState) {
            var result = await apiService.requestInitData();
            if (result.statusCode == 200) {
              globalData.eula = result.body['eula'];
              print(globalData.eula);
              print('Getting resources success');
              initBloc.dispatch(ReadyEvent());
            } else {
              print('There has been an error in getting needed resources.\n Please try again later.\nError Code:'+result.statusCode.toString());
              initBloc.dispatch(ErrorEvent());
            }
          }
        },
        child: BlocBuilder(
            bloc: initBloc,
            builder: (BuildContext context, InitializationState state) {
              if (state is ReadyState)
                return LoginBlocHandler();
              else if (state is ErrorState)
                return ErrorScreen(
                  prompt: 'There has been an error in getting needed resources.\n Please try again later.',
                );
              return LoadingScreen(
                prompt: 'Getting latest resources',
              );
            }),
      ),
    );
  }
}
