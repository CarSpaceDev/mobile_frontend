import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum VehicleStatus { Unverified, Blocked, Rejected, Available, Unavailable, Expired }

enum VehicleType { Motorcycle, Sedan, PickUp, Van, Truck4W, Truck8W }

class Vehicle extends Equatable {
  final String plateNumber;
  // ignore: non_constant_identifier_names
  final String CR;
  final List<dynamic> currentUsers;
  final String ownerId;
  final String vehicleImage;
  final String make;
  final String model;
  final VehicleType type;
  final String color;
  final VehicleStatus status;
  final DateTime expireDate;
  // ignore: non_constant_identifier_names
  final String OR;

  @override
  List<Object> get props =>
      [plateNumber, CR, currentUsers, ownerId, vehicleImage, make, model, type, color, status, OR, expireDate];
  Vehicle.fromDoc(DocumentSnapshot doc)
      : plateNumber = doc.id,
        vehicleImage = doc.data()['vehicleImage'] as String,
        CR = doc.data()['CR'] as String,
        OR = doc.data()['OR'] as String,
        ownerId = doc.data()['ownerId'] as String,
        make = doc.data()['make'] as String,
        model = doc.data()['model'] as String,
        type = VehicleType.values[doc.data()['type']],
        color = doc.data()['color'] as String,
        expireDate = doc.data()["expireDate"].toDate(),
        status = doc.data()["isBlocked"]
            ? VehicleStatus.Blocked
            : doc.data()["isRejected"]
                ? VehicleStatus.Rejected
                : doc.data()['isVerified'] == false
                    ? VehicleStatus.Unverified
                    : DateTime.now().isAfter(doc.data()["expireDate"].toDate())
                        ? VehicleStatus.Expired
                        : doc.data()["status"] == 1
                            ? VehicleStatus.Unavailable
                            : VehicleStatus.Available,
        currentUsers = doc.data()['currentUsers'] as List<dynamic>;

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
      "status": this.status,
      "currentUsers": this.currentUsers,
      "expireDate": this.expireDate
    };
  }

  static String vehicleStatus(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.Unavailable:
        return "Unavailable";
      case VehicleStatus.Unverified:
        return "Unverified";
      case VehicleStatus.Blocked:
        return "Blocked";
      case VehicleStatus.Rejected:
        return "Rejected";
      default:
        return "Available";
    }
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
