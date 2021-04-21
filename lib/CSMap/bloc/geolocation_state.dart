part of 'geolocation_bloc.dart';

abstract class GeolocationState extends Equatable {
  const GeolocationState();
}

class GeolocationInitial extends GeolocationState {
  @override
  List<Object> get props => [];
}
class PositionUpdated extends GeolocationState {
  final CSPosition position;
  PositionUpdated({@required this.position});
  @override
  List<Object> get props => [position];
}