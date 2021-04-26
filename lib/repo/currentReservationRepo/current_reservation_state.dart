part of 'current_reservation_bloc.dart';

abstract class CurrentReservationState extends Equatable {
  const CurrentReservationState();
}

class CurrentReservationInitial extends CurrentReservationState {
  @override
  List<Object> get props => [];
}
