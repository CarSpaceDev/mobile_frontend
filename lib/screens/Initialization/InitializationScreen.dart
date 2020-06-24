import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'bloc.dart';

class InitializationScreen extends StatefulWidget {
  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
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
            var result = await apiService.getResources();
            if (result.statusCode == 200) {
              globalData.colors = result.body['colors'];
              globalData.categories = result.body['categories'];
              globalData.brands = result.body['brands'];
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
                return LoginScreen();
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
