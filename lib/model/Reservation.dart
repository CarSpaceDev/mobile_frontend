import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'Enums.dart';

class Reservation extends Equatable {
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final CSPosition position;
  final String lotAddress;
  final String lotId;
  final double lotPrice;
  final String partnerId;
  final bool partnerRating;
  final bool recurring;
  final String uid;
  final ReservationStatus reservationStatus;
  final ReservationType reservationType;
  final String transactionId;
  final String userId;
  final bool userRating;
  final String vehicleId;

  Reservation.fromDoc(DocumentSnapshot doc)
      : dateCreated = doc.data()["dateCreated"].toDate(),
        dateUpdated = doc.data()["dateCreated"].toDate(),
        position = CSPosition.fromMap(
            {"latitude": doc.data()['g']['geopoint'].latitude, "longitude": doc.data()['g']['geopoint'].longitude}),
        lotAddress = doc.data()["lotAddress"].trimLeft() as String,
        lotId = doc.data()["lotId"] as String,
        lotPrice = doc.data()["lotPrice"] != null ? double.parse("${doc.data()["lotPrice"]}") : null,
        partnerId = doc.data()["partnerId"] as String,
        partnerRating = doc.data()["partnerRating"] as bool,
        recurring = doc.data()["recurring"] as bool,
        uid = doc.id,
        reservationStatus = ReservationStatus.values[doc.data()["reservationStatus"]],
        reservationType = ReservationType.values[doc.data()["reservationType"]],
        transactionId = doc.data()["transactionId"] as String,
        userId = doc.data()["userId"] as String,
        userRating = doc.data()["userRating"] as bool,
        vehicleId = doc.data()["vehicleId"];

  @override
  List<Object> get props => [
        dateCreated,
        dateUpdated,
        position,
        lotAddress,
        lotId,
        lotPrice,
        partnerId,
        partnerRating,
        recurring,
        uid,
        reservationStatus,
        reservationType,
        transactionId,
        userId,
        userRating,
        vehicleId
      ];

  Map<String, dynamic> toJson() => {
        "dateCreated": dateCreated.toString(),
        "dateUpdated": dateUpdated.toString(),
        "position": position.toJson(),
        "lotAddress": lotAddress,
        "lotId": lotId,
        "lotPrice": lotPrice,
        "partnerId": partnerId,
        "partnerRating": partnerRating,
        "recurring": recurring,
        "uid": uid,
        "reservationStatus": reservationStatus,
        "reservationType": reservationType,
        "transactionId": transactionId,
        "userId": userId,
        "userRating": userRating,
        "vehicleId": vehicleId
      };
}
