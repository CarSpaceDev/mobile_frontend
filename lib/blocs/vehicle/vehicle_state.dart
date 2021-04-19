part of 'vehicle_bloc.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();
}

class VehicleInitial extends VehicleState {
  @override
  List<Object> get props => [];
}
