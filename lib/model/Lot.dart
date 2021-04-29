import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/model/Enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'Vehicle.dart';

enum LotStatus { Active, Inactive, Blocked, Rejected, Unverified }

class Lot extends Equatable {
  final String lotId;
  final String partnerId;
  final LotStatus status;
  final String lotImage;
  final LotAddress address;
  final double pricing;
  final double pricePerDay;
  final ParkingType parkingType;
  final VehicleType vehicleTypeAccepted;
  final double rating;
  final int numberOfRatings;
  final int availableFrom;
  final int availableTo;
  final List<int> availableDays;
  final int availableSlots;
  final int capacity;
  final CSPosition coordinates;

  @override
  List<Object> get props => [
        lotId,
        parkingType,
        status,
        lotImage,
        address,
        pricing,
        pricePerDay,
        parkingType,
        vehicleTypeAccepted,
        rating,
        numberOfRatings,
        availableFrom,
        availableTo,
        availableDays,
        availableSlots,
        capacity,
        coordinates,
      ];

  Lot.fromJson(Map<String, dynamic> json)
      : lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        status = json["isBlocked"] == true
            ? LotStatus.Blocked
            : json["isVerified"] == false
                ? LotStatus.Unverified
                : json["isActive"]
                    ? LotStatus.Active
                    : LotStatus.Inactive,
        lotImage = json["lotImage"].length == 1 ? json["lotImage"][0] : json["lotImage"],
        address = LotAddress.fromJson(json["address"]),
        pricing = json["pricing"] != null ? double.parse("${json['pricing']}") : null,
        pricePerDay = json["pricePerDay"] != null ? double.parse("${json['pricePerDay']}") : null,
        parkingType = ParkingType.values[json["parkingType"]],
        vehicleTypeAccepted = VehicleType.values[json["vehicleTypeAccepted"]],
        rating = json["rating"] != null ? double.parse("${json['rating']}") : null,
        numberOfRatings = json["numberOfRatings"] as int,
        availableFrom = int.parse(json["availableFrom"]),
        availableTo = int.parse(json["availableTo"]),
        availableDays = List<int>.from(json["availableDays"]),
        availableSlots = json["availableSlots"] as int,
        capacity = json["capacity"] as int,
        coordinates = CSPosition.fromMap({"latitude": json["coordinates"][0], "longitude": json["coordinates"][1]});

  Lot.fromDoc(DocumentSnapshot doc)
      : lotId = doc.data()["lotId"],
        partnerId = doc.data()["partnerId"],
        status = doc.data()["isBlocked"] == true
            ? LotStatus.Blocked
            : doc.data()["isVerified"] == false
                ? LotStatus.Unverified
                : doc.data()["isActive"]
                    ? LotStatus.Active
                    : LotStatus.Inactive,
        lotImage = doc.data()["lotImage"],
        address = LotAddress.fromJson(doc.data()),
        pricing = doc.data()["pricing"] != null ? double.parse("${doc.data()['pricing']}") : null,
        pricePerDay = doc.data()["pricePerDay"] != null ? double.parse("${doc.data()['pricePerDay']}") : null,
        parkingType = doc.data()["parkingType"] != null ? ParkingType.values[doc.data()["parkingType"]] : null,
        vehicleTypeAccepted =
            doc.data()["vehicleTypeAccepted"] != null ? VehicleType.values[doc.data()["vehicleTypeAccepted"]] : null,
        rating = doc.data()["rating"] != null ? double.parse("${doc.data()['rating']}") : null,
        numberOfRatings = doc.data()["numberOfRatings"],
        availableFrom = int.parse(doc.data()["availableFrom"]),
        availableTo = int.parse(doc.data()["availableTo"]),
        availableDays = List<int>.from(doc.data()["availableDays"]),
        availableSlots = doc.data()["availableSlots"],
        capacity = doc.data()["capacity"],
        coordinates = CSPosition.fromMap(
            {"latitude": doc.data()["coordinates"].latitude, "longitude": doc.data()["coordinates"].longitude});

  Map<String, dynamic> toJson() {
    return {
      "lotId": lotId,
      "partnerId": partnerId,
      "status": status,
      "lotImage": lotImage,
      "address": address.toString(),
      "pricing": pricing,
      "parkingType": parkingType,
      "vehicleTypeAccepted": vehicleTypeAccepted,
      "rating": rating,
      "numberOfRatings": numberOfRatings,
      "availableFrom": availableFrom,
      "availableTo": availableTo,
      "availableDays": availableDays,
      "availableSlots": availableSlots,
      "capacity": capacity,
      "coordinates": coordinates,
      "pricePerDay": pricePerDay,
    };
  }
}

class LotAddress extends Equatable {
  final String houseAndStreet;
  final String brgy;
  final String municipality;
  final String city;
  final String province;
  final String country;
  final String zipCode;

  @override
  List<Object> get props => [houseAndStreet, brgy, municipality, city, province, country, zipCode];

  LotAddress.fromJson(Map<String, dynamic> json)
      : houseAndStreet = json["houseAndStreet"] != null ? "${json["houseAndStreet"]}" : null,
        brgy = json["brgy"] != null ? "${json["brgy"]}" : null,
        municipality = json["municipality"] != null ? "${json["municipality"]}" : null,
        city = json["city"] != null ? "${json["city"]}" : null,
        province = json["province"] != null ? "${json["province"]}" : null,
        country = json["country"] != null ? "${json["country"]}" : null,
        zipCode = json["zipCode"] != null ? "${json["zipCode"]}" : null;

  @override
  String toString() {
    String result = "" +
        "${houseAndStreet != null ? " " + houseAndStreet + "," : ""}" +
        "${brgy != null ? " $brgy," : ""}" +
        "${municipality != null ? " $municipality," : ""}" +
        "${city != null ? " $city," : ""}" +
        "${province != null ? " $province," : ""}" +
        "${zipCode != null ? " $zipCode" : ""}";
    return result;
  }
}
