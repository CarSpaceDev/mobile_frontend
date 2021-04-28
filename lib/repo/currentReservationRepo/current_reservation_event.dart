part of 'current_reservation_bloc.dart';

abstract class CurrentReservationEvent extends Equatable {
  const CurrentReservationEvent();
}

class InitCurrentReservationRepo extends CurrentReservationEvent {
  final String uid;
  InitCurrentReservationRepo({this.uid});
  @override
  List<Object> get props => [uid];
}

class CurrentReservationUpdated extends CurrentReservationEvent {
  final Reservation reservation;
  CurrentReservationUpdated({this.reservation});
  @override
  List<Object> get props => [reservation];
}
  
class DisposeCurrentReservationRepo extends CurrentReservationEvent {
  DisposeCurrentReservationRepo();
  @override
  List<Object> get props => [];
}
