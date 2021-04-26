import 'package:carspace/screens/prompts/ErrorScreen.dart';
import 'package:carspace/screens/prompts/LoadingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/init/initialization_bloc.dart';

class InitializationScreen extends StatefulWidget {
  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    context.bloc<InitializationBloc>().add(BeginInitEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InitializationBloc, InitializationState>(
        listener: (context, state) async {},
        builder: (context, state) {
          if (state is ErrorState)
            return ErrorScreen(
              prompt: state.error == null
                  ? 'There has been an error in getting needed resources.\n Please try again later.'
                  : state.error,
              showButtons: false,
            );
          return LoadingScreen(
            prompt: 'Getting latest resources',
          );
        });
  }
}
