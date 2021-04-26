import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/screens/DriverScreens/DestinationPicker.dart';
import 'package:equatable/equatable.dart';

import 'Vehicle.dart';

enum LotStatus {
  Active,
  Inactive,
  Disabled,
}

class Lot extends Equatable {
  final String lotId;
  final String partnerId;
  final LotStatus status;
  final List<String> lotImage;
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
  final double distance;

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
        distance
      ];

  Lot.fromJson(Map<String, dynamic> json)
      : lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        status = json["isDisabled"]
            ? LotStatus.Disabled
            : json["isActive"]
                ? LotStatus.Active
                : LotStatus.Inactive,
        lotImage = List<String>.from(json["lotImage"]),
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
        coordinates = CSPosition.fromMap({"latitude": json["coordinates"][0], "longitude": json["coordinates"][1]}),
        distance = json["distance"] as double;

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
      "distance": distance,
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
      : houseAndStreet = json["houseAndStreet"].isEmpty ? null : json["houseAndStreet"] as String,
        brgy = json["brgy"].isEmpty ? null : json["brgy"] as String,
        municipality = json["municipality"].isEmpty ? null : json["municipality"] as String,
        city = json["city"].isEmpty ? null : json["city"] as String,
        province = json["province"].isEmpty ? null : json["province"] as String,
        country = json["country"].isEmpty ? null : json["country"] as String,
        zipCode = json["zipCode"].isEmpty ? null : json["zipCode"] as String;

  @override
  String toString() {
    return "" +
        "${(houseAndStreet != null && houseAndStreet != '') ? " " + houseAndStreet + "," : ""}" +
        "${(brgy != null && brgy != '') ? " " + brgy + "," : ""}" +
        "${(municipality != null && municipality != '') ? " " + municipality + "," : ""}" +
        "${(city != null && city != '') ? " " + city + "," : ""}" +
        "${(province != null && province != '') ? " " + province : ""}" +
        "${(zipCode != null && zipCode != '') ? ", " + zipCode : ""}";
  }
}
