import 'package:carspace/services/ApiMapService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
import 'package:carspace/services/UploadService.dart';
import 'package:get_it/get_it.dart';

import 'navigation.dart';

GetIt locator = GetIt.instance;

void setUpServiceLocator() {
  // Services
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<ApiService>(ApiService.create());
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<ApiMapService>(ApiMapService.create());
  locator.registerSingleton<PushMessagingService>(PushMessagingService());
  locator.registerSingleton<UploadService>(UploadService.create());
}
