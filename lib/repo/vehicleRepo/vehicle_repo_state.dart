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
  final HashMap<String, Vehicle> vehiclesCollection;
  VehicleRepoReady({this.vehicles, this.vehiclesCollection});
  @override
  List<Object> get props => [vehicles, vehiclesCollection];
}
