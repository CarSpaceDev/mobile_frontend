import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class InitializationBloc extends Bloc<InitializationEvent, InitializationState> {
  InitializationBloc() : super(null);
  InitializationState get initialState => InitialState();

  @override
  Stream<InitializationState> mapEventToState(
    InitializationEvent event,
  ) async* {
    if (event is ReadyEvent){
      yield ReadyState();
    }
    else if (event is ErrorEvent)
      yield ErrorState();
  }
}
