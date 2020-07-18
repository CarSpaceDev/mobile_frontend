import 'package:carspace/screens/Initialization/InitializationBlocHandler.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants/SizeConfig.dart';
import 'constants/GlobalConstants.dart';
import 'model/GlobalData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
        return GlobalDataHandler();
      });
    });
  }
}

class GlobalDataHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<GlobalData>(
      create: (_) => GlobalData(),
      child: Provider(
        create: (_) => ApiService.create(),
        dispose: (_, ApiService service) => service.client.dispose(),
        child: Provider<AuthService>(
          create: (_) => AuthService(),
          child: MaterialApp(debugShowCheckedModeBanner: false, theme: themeData, home: InitializationBlocHandler()),
        ),
      ),
    );
  }
}
