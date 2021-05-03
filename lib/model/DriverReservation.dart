import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Enums.dart';

class DriverReservation {
  String dateCreated;
  String dateUpdated;
  String lotId;
  String reservationId;
  String partnerId;
  String vehicleId;
  String timeCreated;
  String timeUpdated;
  String lotImage;
  String lotAddress;
  bool userRating;
  bool partnerRating;
  ReservationStatus status;
  ReservationType type;
  LatLng coordinates;

  DriverReservation();

  DriverReservation.fromJson(Map<String, dynamic> json)
      : reservationId = json["reservationId"] as String,
        lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        vehicleId = json["vehicleId"] as String,
        dateCreated = json["dateCreated"] as String,
        dateUpdated = json["dateUpdated"] as String,
        timeCreated = json["timeCreated"] as String,
        timeUpdated = json["timeUpdated"] as String,
        lotImage = json["lotImage"] as String,
        lotAddress = json["lotAddress"] as String,
        userRating = json["userRating"] as bool,
        partnerRating = json["partnerRating"] as bool,
        status = ReservationStatus.values[json['reservationStatus'] as int],
        type = ReservationType.values[json['reservationType'] as int],
        coordinates =
            LatLng(json["g"]["geopoint"]["_latitude"] as double, json["g"]["geopoint"]["_longitude"] as double);

  toJson() {
    return {
      "reservationId": reservationId,
      "lotId": lotId,
      "partnerId": partnerId,
      "vehicleId": vehicleId,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      "timeCreated": timeCreated,
      "timeUpdated": timeUpdated,
      "lotImage": lotImage,
      "lotAddress": lotAddress,
      "status": status,
      "type": type,
      "userRating": userRating,
      "partnerRating": partnerRating,
      "coordinates": coordinates.toString(),
    };
  }
}
