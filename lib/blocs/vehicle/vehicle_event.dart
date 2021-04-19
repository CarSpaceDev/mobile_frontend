part of 'vehicle_bloc.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();
}

class EulaResponseEvent extends VehicleEvent {
  final bool value;
  EulaResponseEvent({this.value});
  @override
  List<Object> get props => [value];
}