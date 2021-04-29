import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'current_reservation_event.dart';
part 'current_reservation_state.dart';

class CurrentReservationBloc extends Bloc<CurrentReservationEvent, CurrentReservationState> {
  CurrentReservationBloc() : super(CurrentReservationInitial());
  StreamSubscription<DocumentSnapshot> currentReservation;

  @override
  Stream<CurrentReservationState> mapEventToState(
    CurrentReservationEvent event,
  ) async* {
    if (event is InitCurrentReservationRepo) {
      print("Initializing UserRepo");
      try {
        currentReservation =
            FirebaseFirestore.instance.collection("reservations").doc(event.uid).snapshots().listen((result) {
          if (result.exists) add(CurrentReservationUpdated(reservation: Reservation.fromDoc(result)));
        });
      } catch (e) {
        print("Initialize Current Reservation Repo Error");
        print(e);
      }
    }
    if (event is CurrentReservationUpdated) {
      print("CurrentReservation Updated");
      yield UpdatedCurrentReservation(reservation: event.reservation);
    }
    if (event is DisposeCurrentReservationRepo) {
      print("DisposeCurrentReservationRepoCalled");
      currentReservation.cancel();
    }
  }
}
