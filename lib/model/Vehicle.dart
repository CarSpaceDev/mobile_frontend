import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String plateNumber;
  // ignore: non_constant_identifier_names
  final String CR;
  final List<dynamic> currentUsers;
  final String ownerId;
  final String vehicleImage;
  final String make;
  final String model;
  final int type;
  final String color;
  final bool isVerified;
  // ignore: non_constant_identifier_names
  final String OR;

  @override
  List<Object> get props =>
      [plateNumber, CR, currentUsers, ownerId, vehicleImage, make, model, type, color, isVerified, OR];
  Vehicle.fromJson(Map<String, dynamic> json)
      : plateNumber = json['plateNumber'] as String,
        vehicleImage = json['vehicleImage'] as String,
        CR = json['CR'] as String,
        OR = json['OR'] as String,
        ownerId = json['ownerId'] as String,
        make = json['make'] as String,
        model = json['model'] as String,
        type = json['type'] as int,
        color = json['color'] as String,
        isVerified = json['isVerified'] as bool,
        currentUsers = json['currentUsers'] as List<dynamic>;

  toJson() {
    return {
      "plateNumber": this.plateNumber,
      "vehicleImage": this.vehicleImage,
      "OR": this.OR,
      "CR": this.CR,
      "ownerId": this.ownerId,
      "make": this.make,
      "model": this.model,
      "type": this.type,
      "color": this.color,
      "isVerified": this.isVerified,
      "currentUsers": this.currentUsers
    };
  }
}

class VehicleAddAuth {
  String plateNumber;
  String vehicleImage;
  String make;
  String model;
  String color;
  String newUser;

  VehicleAddAuth.fromJson(Map<String, dynamic> json)
      : plateNumber = json['plateNumber'] as String,
        vehicleImage = json['vehicleImage'] as String,
        make = json['make'] as String,
        model = json['model'] as String,
        color = json['color'] as String,
        newUser = json['newUser'] as String;

  toJson() {
    return {
      "plateNumber": this.plateNumber,
      "vehicleImage": this.vehicleImage,
      "make": this.make,
      "model": this.model,
      "color": this.color,
      "newUser": this.newUser
    };
  }
}
