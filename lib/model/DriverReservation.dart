import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Enums.dart';

class DriverReservation {
  String reservationId;
  String lotId;
  String partnerId;
  String vehicleId;
  String dateCreated;
  String dateUpdated;
  String timeCreated;
  String timeUpdated;
  String lotImage;
  String lotAddress;
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
      "coordinates": coordinates.toString(),
    };
  }
}
