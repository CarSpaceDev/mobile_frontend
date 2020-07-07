import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'initialization_event.dart';
part 'initialization_state.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  InitializationBloc() : super(InitialState());

  @override
  Stream<InitializationState> mapEventToState(
    InitializationEvent event,
  ) async* {
    if (event is BeginInitEvent)
      yield BeginInitState();
    else if (event is ReadyEvent){
      yield ReadyState();
    }
    else if (event is ErrorEvent)
      yield ErrorState();
  }
}
