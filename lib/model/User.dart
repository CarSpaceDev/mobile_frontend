import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:json_annotation/json_annotation.dart';
//part 'User.g.dart';
//
//@JsonSerializable()
class User {
  //these variables come from the login data
  String uid;
  DateTime lastSignInTime;

  //TODO encrypt the email
  String email;

  //these variables can be overwritten and sent to the API
  String photoUrl;
  String displayName;

  //these variables are taken from the API
  bool isSanctioned;
  DateTime sanctionEnds;
  String filterData;
  String recommendationProfile;
  int boosters;
  int rating;
  String subscriptionType;
  DateTime subscriptionEnd;
  //these variables don't need to be sent to API
  String jwt;
//  Filter filter;
  double distance;

  User({
    this.uid,
    this.lastSignInTime,
    this.displayName,
    this.email,
    this.photoUrl,
    this.filterData,
    this.recommendationProfile,
    this.boosters,
    this.rating,
    this.subscriptionType,
    this.subscriptionEnd,
  });

  User.fromAuthService(FirebaseUser user, String token) {
    this.uid = user.uid;
    this.photoUrl = user.photoUrl;
    this.lastSignInTime = user.metadata.lastSignInTime;
    this.displayName = user.displayName;
    this.email = user.email;
    this.jwt = token;
  }

  User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        lastSignInTime = json['lastSignInTime'],
        displayName = json['displayName'],
        email = json['email'],
        photoUrl = json['photoUrl'],
        filterData = json['filterData'],
        recommendationProfile = json['recommendationProfile'],
        boosters = json['boosters'],
        rating = json['rating'],
        subscriptionType = json['subscriptionType'],
        subscriptionEnd = json['subscriptionEnd'];

  User fromJson(Map<String, dynamic> user) => _$UserFromJson(user);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User _$UserFromJson(Map<String, dynamic> json) {
    return User(
      uid: json['authId'] as String,
      lastSignInTime: json['lastSignInTime'] == null
          ? null
          : DateTime.parse(json['lastSignInTime'] as String),
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String,
      filterData: json['filterData'] as String,
      recommendationProfile: json['recommendationProfile'] as String,
      boosters: json['boosters'] as int,
      rating: json['rating'] as int,
      subscriptionType: json['subscriptionType'] as String,
      subscriptionEnd: json['subscriptionEnd'] == null
          ? null
          : DateTime.parse(json['subscriptionEnd'] as String),
    )
      ..isSanctioned = json['isSanctioned'] as bool
      ..sanctionEnds = json['sanctionEnds'] == null
          ? null
          : DateTime.parse(json['sanctionEnds'] as String)
      ..jwt = json['jwt'] as String
      ..distance = (json['distance'] as num)?.toDouble();
  }

  Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
        'uid': instance.uid,
        'lastSignInTime': instance.lastSignInTime?.toIso8601String(),
        'email': instance.email,
        'photoUrl': instance.photoUrl,
        'displayName': instance.displayName,
        'isSanctioned': instance.isSanctioned,
        'sanctionEnds': instance.sanctionEnds?.toIso8601String(),
        'filterData': instance.filterData,
        'recommendationProfile': instance.recommendationProfile,
        'boosters': instance.boosters,
        'rating': instance.rating,
        'subscriptionType': instance.subscriptionType,
        'subscriptionEnd': instance.subscriptionEnd?.toIso8601String(),
        'jwt': instance.jwt,
        'distance': instance.distance,
      };
}
