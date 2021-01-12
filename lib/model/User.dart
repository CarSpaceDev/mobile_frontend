import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';

class CSUser {
  String uid;
  String displayName;
  String emailAddress;
  String firstName;
  String lastName;
  int credits;
  String phoneNumber;
  String photoUrl;
  //internal attributes
  int partnerAccess;
  int userAccess;
  String subscriptionType;
  //List Items
  List<dynamic> reservations;
  List<dynamic> vehicles;
  //metaData
  DateTime dateCreated;
  DateTime dateUpdated;

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
      this.dateUpdated});

  CSUser.fromUser(User v) {
    this.uid = v.uid;
    this.phoneNumber = v.phoneNumber;
    this.displayName = v.displayName;
    this.photoUrl = v.photoURL;
    this.emailAddress = v.email;
  }

  CSUser.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] as String,
        displayName = json['displayName'] as String,
        emailAddress = json['emailAddress'] as String,
        firstName = json['firstName'] as String,
        lastName = json['lastName'] as String,
        credits = json['credits'] as int,
        phoneNumber = json['phoneNumber'] != null ? json['phoneNumber'].toString() : null,
        photoUrl = json['photoUrl'] as String,
        partnerAccess = json['partnerAccess'] as int,
        userAccess = json['userAccess'] as int,
        subscriptionType = json['subscriptionType'] as String,
        reservations = json['reservations'] as List<dynamic>,
        vehicles = json['vehicles'] as List<dynamic>;

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
      "reservations": this.reservations,
      "vehicles": this.vehicles,
      "dateCreated": this.dateCreated.toIso8601String(),
      "dateUpdated": this.dateUpdated.toIso8601String()
    };
  }
}
