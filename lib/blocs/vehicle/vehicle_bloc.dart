import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial());

  @override
  Stream<VehicleState> mapEventToState(
    VehicleEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
