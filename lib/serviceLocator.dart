import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:get_it/get_it.dart';

import 'model/GlobalData.dart';
import 'navigation.dart';

GetIt locator = GetIt.instance;


void setUpServiceLocator() {
  // Services
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<ApiService>(ApiService.create());
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<GlobalData>(GlobalData());
}

