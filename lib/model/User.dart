import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CSUser extends Equatable {
  final String uid;
  final String displayName;
  final String emailAddress;
  final String firstName;
  final String lastName;
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
        currentReservation = json['currentReservation'] ==null ?  null : json['currentReservation'],
        firstName = json['firstName'] as String,
        lastName = json['lastName'] as String,
        phoneNumber = json['phoneNumber'] == null ? null : json['phoneNumber'].toString(),
        photoUrl = json['photoUrl'] as String,
        partnerAccess = json['partnerAccess'] as int,
        userAccess = json['userAccess'] as int,
        subscriptionType = json['subscriptionType'] as String,
        reservations = json['reservations'] as List<dynamic>,
        vehicles = json['vehicles'] as List<dynamic>,
        currentVehicle = json['currentVehicle'] as String,
        dateUpdated =  DateTime.fromMillisecondsSinceEpoch(json["dateCreated"]["seconds"]),
        dateCreated = DateTime.fromMillisecondsSinceEpoch(json["dateUpdated"]["seconds"]);

  CSUser.fromDoc(DocumentSnapshot doc)
      : uid = doc.data()['uid'] as String,
        displayName = doc.data()['displayName'] as String,
        emailAddress = doc.data()['emailAddress'] as String,
        currentReservation = doc.data()['currentReservation'] as String,
        firstName = doc.data()['firstName'] as String,
        lastName = doc.data()['lastName'] as String,
        phoneNumber = doc.data()['phoneNumber'] != null ? doc.data()['phoneNumber'].toString() : null,
        photoUrl = doc.data()['photoUrl'] as String,
        partnerAccess = doc.data()['partnerAccess'] as int,
        userAccess = doc.data()['userAccess'] as int,
        subscriptionType = doc.data()['subscriptionType'] as String,
        reservations = doc.data()['reservations'] as List<dynamic>,
        vehicles = doc.data()['vehicles'] as List<dynamic>,
        currentVehicle = doc.data()['currentVehicle'] as String,
        dateUpdated =  doc.data()['dateCreated'].toDate(),
        dateCreated = doc.data()['dateUpdated'].toDate();

  Map<String, dynamic> toJson() {
    return {
      "userId": this.uid,
      "displayName": this.displayName,
      "emailAddress": this.emailAddress,
      "firstName": this.firstName,
      "lastName": this.lastName,
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
