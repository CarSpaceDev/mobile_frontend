import 'package:carspace/serviceLocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'blocs/init/initialization_bloc.dart';
import 'blocs/login/login_bloc.dart';
import 'constants/GlobalConstants.dart';
import 'constants/SizeConfig.dart';
import 'navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var path = await getApplicationDocumentsDirectory();
  Hive..init(path.path);
  await Hive.openBox('localCache');
  await Firebase.initializeApp();
  setUpServiceLocator();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.indigo[900], statusBarColor: Colors.indigo[900]));

  runApp(CarSpaceApp());
}

class CarSpaceApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeConfig().init(constraints, orientation);
        return MultiBlocProvider(
          providers: [
            BlocProvider<InitializationBloc>(
              create: (BuildContext context) => InitializationBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => LoginBloc(),
            ),
          ],
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeData,
              builder: (context, child) => child,
              navigatorKey: locator<NavigationService>().navigatorKey,
              onGenerateRoute: generateRoute,
              initialRoute: InitializationRoute),
          //     MaterialApp(
          //   debugShowCheckedModeBanner: false,
          //   home: HomeScreen(),
          // ),
        );
      });
    });
  }
}
