part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();
}

class MapInitial extends MapState {
  @override
  List<Object> get props => [];
}
class MapSettingsReady extends MapState {
  final MapSettings settings;
  MapSettingsReady({@required this.settings});
  @override
  List<Object> get props => [settings];
}
