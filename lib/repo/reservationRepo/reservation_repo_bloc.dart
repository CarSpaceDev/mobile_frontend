import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'reservation_repo_event.dart';
part 'reservation_repo_state.dart';

class ReservationRepoBloc extends Bloc<ReservationRepoEvent, ReservationRepoState> {
  ReservationRepoBloc() : super(ReservationRepoInitial());
  StreamSubscription<QuerySnapshot> reservations;
  @override
  Stream<ReservationRepoState> mapEventToState(
    ReservationRepoEvent event,
  ) async* {
    if (event is InitializeReservationRepo) {
      var repoReference;
      if (event.isPartner) {
        repoReference = FirebaseFirestore.instance
            .collection("reservations")
            .where("partnerId", isEqualTo: locator<AuthService>().currentUser().uid);
      } else {
        repoReference = FirebaseFirestore.instance
            .collection("reservations")
            .where("userId", isEqualTo: locator<AuthService>().currentUser().uid);
      }
      reservations = repoReference.orderBy("dateCreated", descending: true).snapshots().listen((result) {
        List<Reservation> temp = [];
        for (QueryDocumentSnapshot doc in result.docs) {
          temp.add(Reservation.fromDoc(doc));
        }
        add(ReservationsUpdated(reservations: temp));
      });
    }
    if (event is ReservationsUpdated) {
      yield ReservationRepoReady(reservations: event.reservations);
    }
    if (event is DisposeReservationRepo) {
      print("ReservationRepoDispose");
      await reservations.cancel();
    }
  }
}
