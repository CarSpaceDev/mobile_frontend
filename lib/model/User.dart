import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CSUser extends Equatable {
  final String uid;
  final String displayName;
  final String emailAddress;
  final String firstName;
  final String lastName;
  final int credits;
  final String phoneNumber;
  final String photoUrl;
  final String currentReservation;
  final String currentVehicle;
  //internal attributes
  final int partnerAccess;
  final int userAccess;
  final String subscriptionType;
  //List Items
  final List<dynamic> reservations;
  final List<dynamic> vehicles;
  //metaData
  final DateTime dateCreated;
  final DateTime dateUpdated;

  @override
  List<Object> get props => [
        uid,
        displayName,
        emailAddress,
        firstName,
        lastName,
        credits,
        phoneNumber,
        photoUrl,
        currentReservation,
        currentVehicle,
        partnerAccess,
        userAccess,
        subscriptionType,
        reservations,
        vehicles,
        dateCreated,
        dateUpdated
      ];

  CSUser(
      {this.uid,
      this.displayName,
      this.emailAddress,
      this.firstName,
      this.lastName,
      this.credits,
      this.phoneNumber,
      this.photoUrl,
      this.partnerAccess,
      this.userAccess,
      this.subscriptionType,
      this.reservations,
      this.vehicles,
      this.dateCreated,
      this.dateUpdated,
      this.currentVehicle,
      this.currentReservation});

  CSUser.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] as String,
        displayName = json['displayName'] as String,
        emailAddress = json['emailAddress'] as String,
        currentReservation = json['currentReservation'] as String,
        firstName = json['firstName'] as String,
        lastName = json['lastName'] as String,
        credits = json['credits'] as int,
        phoneNumber = json['phoneNumber'] != null ? json['phoneNumber'].toString() : null,
        photoUrl = json['photoUrl'] as String,
        partnerAccess = json['partnerAccess'] as int,
        userAccess = json['userAccess'] as int,
        subscriptionType = json['subscriptionType'] as String,
        reservations = json['reservations'] as List<dynamic>,
        vehicles = json['vehicles'] as List<dynamic>,
        currentVehicle = json['currentVehicle'] as String,
        dateUpdated =  Timestamp(json['dateCreated']["_seconds"], json['dateCreated']["_nanoseconds"]).toDate(),
        dateCreated = Timestamp(json['dateUpdated']["_seconds"], json['dateUpdated']["_nanoseconds"]).toDate();

  CSUser.fromDoc(DocumentSnapshot json)
      : uid = json.data()['uid'] as String,
        displayName = json.data()['displayName'] as String,
        emailAddress = json.data()['emailAddress'] as String,
        currentReservation = json.data()['currentReservation'] as String,
        firstName = json.data()['firstName'] as String,
        lastName = json.data()['lastName'] as String,
        credits = json.data()['credits'] as int,
        phoneNumber = json.data()['phoneNumber'] != null ? json.data()['phoneNumber'].toString() : null,
        photoUrl = json.data()['photoUrl'] as String,
        partnerAccess = json.data()['partnerAccess'] as int,
        userAccess = json.data()['userAccess'] as int,
        subscriptionType = json.data()['subscriptionType'] as String,
        reservations = json.data()['reservations'] as List<dynamic>,
        vehicles = json.data()['vehicles'] as List<dynamic>,
        currentVehicle = json.data()['currentVehicle'] as String,
        dateUpdated =  json.data()['dateCreated'].toDate(),
        dateCreated = json.data()['dateUpdated'].toDate();

  Map<String, dynamic> toJson() {
    return {
      "userId": this.uid,
      "displayName": this.displayName,
      "emailAddress": this.emailAddress,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "credits": this.credits,
      "phoneNumber": this.phoneNumber,
      "photoUrl": this.photoUrl,
      "partnerAccess": this.partnerAccess,
      "userAccess": this.userAccess,
      "subscriptionType": this.subscriptionType,
      "currentReservation": this.currentReservation,
      "reservations": this.reservations,
      "vehicles": this.vehicles,
    };
  }
}
