part of 'vehicle_repo_bloc.dart';

abstract class VehicleRepoState extends Equatable {
  const VehicleRepoState();
}

class VehicleRepoInitial extends VehicleRepoState {
  @override
  List<Object> get props => [];
}

class VehicleRepoReady extends VehicleRepoState {
  final List<Vehicle> vehicles;
  VehicleRepoReady({this.vehicles});
  @override
  List<Object> get props => [vehicles];
}
