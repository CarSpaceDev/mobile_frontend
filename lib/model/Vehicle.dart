import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

enum VehicleStatus { Unverified, Blocked, Rejected, Available, Unavailable, Expired }

enum VehicleType { Motorcycle, Sedan, PickUp, Van, Truck4W, Truck8W }

class Vehicle extends Equatable {
  final String plateNumber;
  final String OR;
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
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final bool isBlocked;
  final bool isRejected;
  final bool isVerified;

  @override
  List<Object> get props => [
        plateNumber,
        CR,
        currentUsers,
        ownerId,
        vehicleImage,
        make,
        model,
        type,
        color,
        status,
        OR,
        expireDate,
        dateCreated,
        dateUpdated,
        isBlocked,
        isRejected,
        isVerified,
      ];
  Vehicle({
    @required String plateNumber,
    @required String OR,
    @required String CR,
    @required List<dynamic> currentUsers,
    @required String ownerId,
    @required String vehicleImage,
    @required String make,
    @required String model,
    @required VehicleType type,
    @required String color,
    @required VehicleStatus status,
    @required DateTime expireDate,
    @required DateTime dateCreated,
    @required DateTime dateUpdated,
    @required bool isBlocked,
    @required bool isRejected,
    @required bool isVerified,
  })  : plateNumber = plateNumber,
        OR = OR,
        CR = CR,
        currentUsers = currentUsers,
        ownerId = ownerId,
        vehicleImage = vehicleImage,
        make = make,
        model = model,
        type = type,
        color = color,
        status = status,
        expireDate = expireDate,
        dateCreated = dateCreated,
        dateUpdated = dateUpdated,
        isBlocked = isBlocked,
        isRejected = isRejected,
        isVerified = isVerified;
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
        dateCreated = doc.data()["dateCreated"].toDate(),
        dateUpdated = doc.data()["dateUpdated"].toDate(),
        isBlocked = doc.data()["isBlocked"],
        isRejected = doc.data()["isRejected"],
        isVerified = doc.data()["isRejected"],
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
      "type": this.type.index,
      "color": this.color,
      "status": this.status.index,
      "currentUsers": this.currentUsers,
      "expireDate": this.expireDate,
      "dateCreated": this.dateCreated,
      "dateUpdated": this.dateUpdated,
      "isBlocked": this.isBlocked,
      "isRejected": this.isRejected,
      "isVerified": this.isVerified,
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
