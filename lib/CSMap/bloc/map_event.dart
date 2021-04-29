part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
}

class InitializeMapSettings extends MapEvent {
  @override
  List<Object> get props => [];
}
class InitializeStaticMapSettings extends MapEvent {
  final CSPosition position;
  InitializeStaticMapSettings({this.position});
  @override
  List<Object> get props => [position];
}
class UpdateMap extends MapEvent {
  final MapSettings settings;
  UpdateMap({@required this.settings});
  @override
  List<Object> get props => [settings];
}
class UpdateMapPosition extends MapEvent {
  final CSPosition position;
  UpdateMapPosition({@required this.position});
  @override
  List<Object> get props => [position];
}
class ShowDestinationMarker extends MapEvent {
  final Marker marker;
  ShowDestinationMarker({@required this.marker});
  @override
  List<Object> get props => [marker];
}