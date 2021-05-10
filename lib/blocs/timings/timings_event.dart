part of 'timings_bloc.dart';

enum TimingsType { Initialization, Login, CashIn, MapLoad, Booking, Navigation, EndBooking }

abstract class TimingsEvent extends Equatable {
  const TimingsEvent();
}

class StartTest extends TimingsEvent {
  final TimingsType type;
  StartTest({this.type});
  @override
  List<Object> get props => [type];
}

class EndTest extends TimingsEvent {
  final TimingsType type;
  EndTest({this.type});
  @override
  List<Object> get props => [type];
}

class GetResults extends TimingsEvent {
  GetResults();
  @override
  List<Object> get props => [];
}

class GetResultsPopUp extends TimingsEvent {
  GetResultsPopUp();
  @override
  List<Object> get props => [];
}
