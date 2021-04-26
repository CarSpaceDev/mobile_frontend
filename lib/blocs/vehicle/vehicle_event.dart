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

class UpdateVehicleDetails extends VehicleEvent {
  final Vehicle vehicle;
  UpdateVehicleDetails({this.vehicle});
  @override
  List<Object> get props => [vehicle];
}

class RevokeVehiclePermission extends VehicleEvent {
  final String uid;
  final Vehicle vehicle;
  RevokeVehiclePermission({this.vehicle, this.uid});
  @override
  List<Object> get props => [uid,vehicle];
}

class RemoveVehicle extends VehicleEvent {
  final Vehicle vehicle;
  RemoveVehicle({this.vehicle});
  @override
  List<Object> get props => [vehicle];
}
class DeleteVehicle extends VehicleEvent {
  final Vehicle vehicle;
  DeleteVehicle({this.vehicle});
  @override
  List<Object> get props => [vehicle];
}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;
  AddVehicle({@required this.vehicle});
  @override
  List<Object> get props => [vehicle];
}
