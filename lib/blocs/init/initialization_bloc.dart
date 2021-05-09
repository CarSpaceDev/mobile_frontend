import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/blocs/timings/timings_bloc.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  final ApiService _apiService = locator<ApiService>();
  final NavigationService _navService = locator<NavigationService>();
  final cache = Hive.box("localCache");
  InitializationBloc() : super(InitialState());
  @override
  Stream<InitializationState> mapEventToState(
    InitializationEvent event,
  ) async* {
    if (event is InitializeAppAssets) {
      try {
        locator<NavigationService>()
            .navigatorKey
            .currentContext
            .read<TimingsBloc>()
            .add(StartTest(type: TimingsType.Initialization));
        yield InitialState();
        var existingCache = cache.get("data");
        if (existingCache == null) {
          var result = await _apiService.requestInitData(hash: DateTime.now().millisecondsSinceEpoch.toString());
          if (result.statusCode == 200) {
            cache.put('data', result.body["data"]);
            locator<NavigationService>()
                .navigatorKey
                .currentContext
                .read<TimingsBloc>()
                .add(EndTest(type: TimingsType.Initialization));
            _navService.pushReplaceNavigateTo(LoginRoute);
          } else {
            yield ErrorState(
                error: 'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                    result.statusCode.toString());
          }
        } else {
          var result = await _apiService.requestInitData(hash: existingCache["hash"]);
          if (result.statusCode == 200) {
            if (result.body["data"].runtimeType == bool) {
              locator<NavigationService>()
                  .navigatorKey
                  .currentContext
                  .read<TimingsBloc>()
                  .add(EndTest(type: TimingsType.Initialization));
              _navService.pushReplaceNavigateTo(LoginRoute);
            } else {
              cache.put('data', result.body["data"]);
              locator<NavigationService>()
                  .navigatorKey
                  .currentContext
                  .read<TimingsBloc>()
                  .add(EndTest(type: TimingsType.Initialization));
              _navService.pushReplaceNavigateTo(LoginRoute);
            }
          } else {
            yield ErrorState(
                error: 'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                    result.statusCode.toString());
          }
        }
      } catch (e) {
        yield ErrorState(error: e.toString());
      }
    }
  }
}
