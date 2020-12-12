import 'dart:core';

class CSUser {
  String uid;
  String displayName;
  String emailAddress;
  String firstName;
  String lastName;
  double credits;
  String phoneNumber;
  String photoUrl;
  //internal attributes
  int partnerAccess;
  int userAccess;
  String subscriptionType;
  //List Items
  List<String> reservations;
  List<String> vehicles;
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

  CSUser.fromJson(Map<String, dynamic> json)
      : uid = json['uid'] as String,
        displayName = json['displayName'] as String,
        emailAddress = json['emailAddress'] as String,
        firstName = json['firstName'] as String,
        lastName = json['lastName'] as String,
        credits = json['credits'] as double,
        phoneNumber =
            json['phoneNumber'] != null ? json['phoneNumber'] as String : null,
        photoUrl = json['photoUrl'] as String,
        partnerAccess = json['partnerAccess'] as int,
        userAccess = json['userAccess'] as int,
        subscriptionType = json['subscriptionType'] as String,
        reservations = json['reservations'] as List<String>,
        vehicles = json['vehicles'] as List<String>,
        dateCreated = DateTime.parse(json['dateCreated'] as String),
        dateUpdated = DateTime.parse(json['dateUpdated'] as String);

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
