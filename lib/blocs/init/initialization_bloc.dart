import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/DevTools.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../serviceLocator.dart';

part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc
    extends Bloc<InitializationEvent, InitializationState> {
  final ApiService apiService = locator<ApiService>();
  final GlobalData globalData = locator<GlobalData>();
  InitializationBloc() : super(InitialState());
  @override
  Stream<InitializationState> mapEventToState(
    InitializationEvent event,
  ) async* {
    if (event is BeginInitEvent) {
      try {
        devLog("InitialState", "InitialState Check");
        var result = await apiService.requestInitData();
        if (result.statusCode == 200) {
          globalData.eula = result.body['eula'];
          devLog("EULA", globalData.eula);
          yield ReadyState();
        } else {
          devLog(
              "InitError",
              'There has been an error in getting needed resources.\n Please try again later.\nError Code:' +
                  result.statusCode.toString());
          yield ErrorState();
        }
      }catch (e){
        print (e.toString());
        yield ErrorState(error: e.toString());
      }
    }
  }
}
