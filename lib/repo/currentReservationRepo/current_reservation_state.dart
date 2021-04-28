part of 'current_reservation_bloc.dart';

abstract class CurrentReservationState extends Equatable {
  const CurrentReservationState();
}

class CurrentReservationInitial extends CurrentReservationState {
  @override
  List<Object> get props => [];
}
class UpdatedCurrentReservation extends CurrentReservationState {
  final Reservation reservation;
  UpdatedCurrentReservation({this.reservation});
  @override
  List<Object> get props => [reservation];
}
