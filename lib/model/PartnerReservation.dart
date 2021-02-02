import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Enums.dart';

class PartnerReservation {
  String reservationId;
  String lotId;
  String partnerId;
  String driverId;
  String vehicleId;
  String displayName;
  String emailAddress;
  String photoUrl;
  String phoneNumber;
  String dateCreated;
  String dateUpdated;
  String timeCreated;
  String timeUpdated;
  String lotImage;
  String lotAddress;
  ReservationStatus status;
  ReservationType type;
  LatLng coordinates;

  PartnerReservation();

  PartnerReservation.fromJson(Map<String, dynamic> json)
      : reservationId = json["reservationId"] as String,
        lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        driverId = json["userId"] as String,
        vehicleId = json["vehicleId"] as String,
        displayName = json["displayName"] as String,
        emailAddress = json["emailAddress"] as String,
        photoUrl = json["photoUrl"] as String,
        phoneNumber = json["phoneNumber"] as String,
        dateCreated = json["dateCreated"] as String,
        dateUpdated = json["dateUpdated"] as String,
        timeCreated = json["timeCreated"] as String,
        timeUpdated = json["timeUpdated"] as String,
        lotImage = json["lotImage"] as String,
        lotAddress = json["lotAddress"] as String,
        status = ReservationStatus.values[json['reservationStatus'] as int],
        type = ReservationType.values[json['reservationType'] as int],
        coordinates = LatLng(json["g"]["geopoint"]["_latitude"] as double, json["g"]["geopoint"]["_longitude"] as double);

  toJson() {
    return {
      "reservationId": reservationId,
      "lotId": lotId,
      "partnerId": partnerId,
      "vehicleId": vehicleId,
      "driverId": driverId,
      "displayName": displayName,
      "emailAddress": emailAddress,
      "photoUrl": photoUrl,
      "phoneNumber": phoneNumber,
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
