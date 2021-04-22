import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'csmain_event.dart';
part 'csmain_state.dart';

class CSMainBloc extends Bloc<CSMainEvent, CSMainState> {
  CSMainBloc() : super(CSMainInitial());

  @override
  Stream<CSMainState> mapEventToState(
    CSMainEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
