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
  final String plateNumber;
  final int type;
  final String color;
  // ignore: non_constant_identifier_names
  final String OR;
  // ignore: non_constant_identifier_names
  final String CR;
  final String vehicleImage;
  final String make;
  final String model;
  final bool fromHomeScreen;
  // ignore: non_constant_identifier_names
  AddVehicle(
      {this.plateNumber,
      this.type,
      this.color,
      // ignore: non_constant_identifier_names
      this.OR,
      // ignore: non_constant_identifier_names
      this.CR,
      this.vehicleImage,
      this.make,
      this.model,
      this.fromHomeScreen});
  @override
  List<Object> get props => [plateNumber, type, color, OR, CR, make, model];
}
