import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/repo/notificationRepo/notification_bloc.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'blocs/init/initialization_bloc.dart';
import 'blocs/login/login_bloc.dart';
import 'blocs/vehicle/vehicle_bloc.dart';
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
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
      .copyWith(systemNavigationBarColor: Colors.indigo[900], statusBarColor: Colors.indigo[900]));

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
            BlocProvider(
              create: (BuildContext context) => InitializationBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => UserRepoBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => VehicleRepoBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => VehicleBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => LoginBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => GeolocationBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => NotificationBloc(),
            ),
            BlocProvider(
              create: (BuildContext context) => WalletBloc(),
            ),
          ],
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: csStyle.theme(),
              builder: (context, child) => child,
              navigatorKey: locator<NavigationService>().navigatorKey,
              onGenerateRoute: generateRoute,
              initialRoute: InitializationRoute),
        );
      });
    });
  }
}
