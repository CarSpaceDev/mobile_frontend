import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'csmain_event.dart';
part 'csmain_state.dart';

class CsmainBloc extends Bloc<CsmainEvent, CsmainState> {
  CsmainBloc() : super(CsmainInitial());

  @override
  Stream<CsmainState> mapEventToState(
    CsmainEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
