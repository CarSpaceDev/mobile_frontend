part of 'reservation_repo_bloc.dart';

abstract class ReservationRepoEvent extends Equatable {
  const ReservationRepoEvent();
}

class InitializeReservationRepo extends ReservationRepoEvent {
  final bool isPartner;
  final String uid;
  InitializeReservationRepo({this.uid, this.isPartner = false});
  @override
  List<Object> get props => [uid];
}

class ReservationsUpdated extends ReservationRepoEvent {
  final List<Reservation> reservations;
  ReservationsUpdated({this.reservations});
  @override
  List<Object> get props => [reservations];
}

class DisposeReservationRepo extends ReservationRepoEvent {
  @override
  List<Object> get props => [];
}
