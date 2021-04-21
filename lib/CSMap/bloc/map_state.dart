part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}
class MapReady extends MapState {
  final Widget map;
  MapReady({@required this.map});
  @override
  List<Object> get props => [map];
}
