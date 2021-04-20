part of 'vehicle_bloc.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();
}

class SetSelectedVehicle extends VehicleEvent {
  final Vehicle vehicle;
  SetSelectedVehicle({this.vehicle});
  @override
  List<Object> get props => [vehicle];
}