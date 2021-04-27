part of 'geolocation_bloc.dart';

enum GeolocationError { LocationServiceDisabled, NoPermission }

abstract class GeolocationEvent extends Equatable {
  const GeolocationEvent();
}

class InitializeGeolocator extends GeolocationEvent {
  @override
  List<Object> get props => [];
}
class StartGeolocation extends GeolocationEvent {
  @override
  List<Object> get props => [];
}

class StartGeolocationBroadcast extends GeolocationEvent {
  final Reservation reservation;
  StartGeolocationBroadcast({@required this.reservation});
  @override
  List<Object> get props => [reservation];
}

class GeolocationErrorDetected extends GeolocationEvent {
  final GeolocationError status;
  GeolocationErrorDetected({@required this.status});
  @override
  List<Object> get props => [status];
}

class RequestPermission extends GeolocationEvent {
  @override
  List<Object> get props => [];
}

class UpdatePosition extends GeolocationEvent {
  final CSPosition position;
  UpdatePosition({@required this.position});
  @override
  List<Object> get props => [position];
}

class UpdatePositionManual extends GeolocationEvent {
  final CSPosition position;
  UpdatePositionManual({@required this.position});
  @override
  List<Object> get props => [position];
}


class CloseGeolocationStream extends GeolocationEvent {
  @override
  List<Object> get props => [];
}
