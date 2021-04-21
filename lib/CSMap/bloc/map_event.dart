part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
}

class InitializeMap extends MapEvent {
  @override
  List<Object> get props => [];
}
class UpdateMap extends MapEvent {
  @override
  List<Object> get props => [];
}
class UpdateMapPosition extends MapEvent {
  final CSPosition position;
  UpdateMapPosition({@required this.position});
  @override
  List<Object> get props => [position];
}