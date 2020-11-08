import 'package:carspace/screens/Initialization/InitializationBlocHandler.dart';
import 'package:carspace/screens/Initialization/initialization_bloc.dart';
import 'package:carspace/screens/login/login_bloc.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'constants/SizeConfig.dart';
import 'constants/GlobalConstants.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpServiceLocator();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.indigo[900],
      statusBarColor: Colors.indigo[900]));
  runApp(CarSpaceApp());
}

class CarSpaceApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeConfig().init(constraints, orientation);
        return GlobalDataHandler();
      });
    });
  }
}

class GlobalDataHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InitializationBloc>(
          create: (BuildContext context) => InitializationBloc(),
        ),
        BlocProvider(
        create: (BuildContext context) => LoginBloc(),),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: InitializationBlocHandler()),
//
    );
  }
}
