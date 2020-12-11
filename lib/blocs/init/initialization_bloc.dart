import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/DevTools.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../serviceLocator.dart';

part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc
    extends Bloc<InitializationEvent, InitializationState> {
  final ApiService apiService = locator<ApiService>();
  final NavigationService navService = locator<NavigationService>();
  final cache = Hive.box("localCache");
  InitializationBloc() : super(InitialState());
  @override
  Stream<InitializationState> mapEventToState(
    InitializationEvent event,
  ) async* {
    if (event is BeginInitEvent) {
      try {
        var existingCache = cache.get("data");
        if (existingCache == null) {
          var result = await apiService.requestInitData(
              hash: DateTime.now().millisecondsSinceEpoch.toString());
          if (result.statusCode == 200) {
            cache.put('data', result.body["data"]);
            print(cache.get('data'));
            print("No cache, got latest cache and navigating to Login");
            navService.pushReplaceNavigateTo(LoginRoute);
          } else {
            devLog(
                "InitError",
                'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                    result.statusCode.toString());
            yield ErrorState();
          }
        } else {
          var result =
              await apiService.requestInitData(hash: existingCache["hash"]);
          if (result.statusCode == 200) {
            if (result.body["data"].runtimeType == bool) {
              print("Cache is up to date, proceeding to Login");
              navService.pushReplaceNavigateTo(LoginRoute);
            } else {
              cache.put('data', result.body["data"]);
              print("Cache is not up to date, saving new data, proceeding to Login");
              navService.pushReplaceNavigateTo(LoginRoute);
            }
          } else {
            devLog(
                "InitError",
                'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                    result.statusCode.toString());
            yield ErrorState();
          }
        }
      } catch (e) {
        print(e.toString());
        yield ErrorState(error: e.toString());
      }
    }
  }
}
