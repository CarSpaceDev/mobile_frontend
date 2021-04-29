part of 'vehicle_repo_bloc.dart';

abstract class VehicleRepoEvent extends Equatable {
  const VehicleRepoEvent();
}

class InitializeVehicleRepo extends VehicleRepoEvent {
  final String uid;
  InitializeVehicleRepo({this.uid});
  @override
  List<Object> get props => [uid];
}

class UpdateVehicleRepo extends VehicleRepoEvent {
  final List<Vehicle> vehicles;
  UpdateVehicleRepo({this.vehicles});
  @override
  List<Object> get props => [vehicles];
}

class VehicleRepoError extends VehicleRepoEvent {
  final dynamic error;
  VehicleRepoError({this.error});
  @override
  List<Object> get props => [error];
}

class DisposeVehicleRepo extends VehicleRepoEvent {
  @override
  List<Object> get props => [];
}

