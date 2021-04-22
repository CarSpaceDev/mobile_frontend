part of 'geolocation_bloc.dart';

enum GeolocationStatus { LocationServiceDisabled, NoPermission, Active }

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

class GeolocationErrorDetected extends GeolocationEvent {
  final GeolocationStatus status;
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

class CloseGeolocationStream extends GeolocationEvent {
  @override
  List<Object> get props => [];
}
