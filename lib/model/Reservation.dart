import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:equatable/equatable.dart';

import 'Enums.dart';

class Reservation extends Equatable {
  final String uid;
  final String lotId;
  final String partnerId;
  final ReservationStatus reservationStatus;
  final String vehicleId;
  final VehicleType reservationType;
  final String lotImage;
  final LotAddress address;
  final CSPosition position;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  Reservation.fromJson(Map<String, dynamic> json)
      : uid = json["reservationId"] as String,
        lotId = json["lotId"] as String,
        partnerId = json["partnerId"] as String,
        dateCreated = DateTime.parse(json["dateCreated"]),
        dateUpdated = DateTime.parse(json["dateUpdated"]),
        reservationStatus = ReservationStatus.values[json["reservationStatus"]],
        vehicleId = json["vehicleId"],
        reservationType = VehicleType.values[json["reservationType"]],
        lotImage = json["lotImage"] as String,
        position = CSPosition.fromMap({"latitude": json["latitude"], "longitude": json["longitude"]}),
        address = LotAddress.fromJson(json);

  @override
  List<Object> get props => [
        uid,
        lotId,
        partnerId,
        reservationStatus,
        vehicleId,
        reservationType,
        lotImage,
        address,
        position,
        dateCreated,
        dateUpdated
      ];

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "lotId": lotId,
        "partnerId": partnerId,
        "reservationStatus": reservationStatus,
        "vehicleId": vehicleId,
        "reservationType": reservationType,
        "lotImage": lotImage,
        "address": address.toString(),
        "position": position.toJson(),
        "dateCreated": dateCreated.toString(),
        "dateUpdated": dateUpdated.toString()
      };
}
