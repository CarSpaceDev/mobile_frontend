part of 'reservation_repo_bloc.dart';

abstract class ReservationRepoState extends Equatable {
  const ReservationRepoState();
}

class ReservationRepoInitial extends ReservationRepoState {
  @override
  List<Object> get props => [];
}

class ReservationRepoReady extends ReservationRepoState {
  final List<Reservation> reservations;
  ReservationRepoReady({this.reservations});
  @override
  List<Object> get props => [reservations];
}

class ReservationRepoError extends ReservationRepoState {
  ReservationRepoError();
  @override
  List<Object> get props => [];
}
