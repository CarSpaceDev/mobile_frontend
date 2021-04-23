import 'package:equatable/equatable.dart';

class Lot extends Equatable {
  final String lotId;
  final String partnerId;
  final List<String> lotImage;
  final LotAddress address;
  final double pricing;
  final double pricePerDay;
  final int parkingType;
  final int vehicleTypeAccepted;
  final bool isActive;
  final double rating;
  final int numberOfRatings;
  final int availableFrom;
  final int availableTo;
  final List<int> availableDays;
  final int availableSlots;
  final int capacity;
  final bool isDisabled;
  final List<double> coordinates;
  final double distance;

  @override
  List<Object> get props => [
        lotId,
        parkingType,
        lotImage,
        address,
        pricing,
        pricePerDay,
        parkingType,
        vehicleTypeAccepted,
        isActive,
        rating,
        numberOfRatings,
        availableFrom,
        availableTo,
        availableDays,
        availableSlots,
        capacity,
        isDisabled,
        coordinates,
        distance
      ];

  Lot.fromJson(Map<String, dynamic> json)
      : lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        isActive = json["isActive"] as bool,
        isDisabled = json["isDisabled"] as bool,
        lotImage = List<String>.from(json["lotImage"]),
        address = LotAddress.fromJson(json["address"]),
        pricing =
            double.parse(int.parse(json["pricing"].toString()).toString()),
        pricePerDay =
            double.parse(int.parse(json["pricePerDay"].toString()).toString()),
        parkingType = json["parkingType"] as int,
        vehicleTypeAccepted = json["vehicleTypeAccepted"] as int,
        rating = json["rating"] as double,
        numberOfRatings = json["numberOfRatings"] as int,
        availableFrom = int.parse(json["availableFrom"]),
        availableTo = int.parse(json["availableTo"]),
        availableDays = List<int>.from(json["availableDays"]),
        availableSlots = json["availableSlots"] as int,
        capacity = json["capacity"] as int,
        coordinates = List<double>.from(json["coordinates"]),
        distance = json["distance"] as double;

  Map<String, dynamic> toJson() {
    return {
      "lotId": lotId,
      "partnerId": partnerId,
      "isActive": isActive,
      "isDisabled": isDisabled,
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
  List<Object> get props =>
      [houseAndStreet, brgy, municipality, city, province, country, zipCode];

  LotAddress.fromJson(Map<String, dynamic> json)
      : houseAndStreet = json["houseAndStreet"] as String,
        brgy = json["brgy"] as String,
        municipality = json["municipality"] as String,
        city = json["city"] as String,
        province = json["province"] as String,
        country = json["country"] as String,
        zipCode = json["zipCode"] as String;

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
