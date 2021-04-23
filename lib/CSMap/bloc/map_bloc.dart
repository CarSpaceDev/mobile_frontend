import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'classes.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapSettings settings;

  MapBloc() : super(MapInitial());

  @override
  Stream<MapState> mapEventToState(
    MapEvent event,
  ) async* {
    if (event is InitializeMapSettings) {
      List<dynamic> result = await Future.wait([
        rootBundle.loadString('assets/mapPOI.txt'),
        rootBundle.loadString('assets/mapStyle.txt'),
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png'),
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png')
      ]);
      settings = MapSettings(mapStylePOI: result[0], mapStyle: result[1], lotIcon: result[2], driverIcon: result[3],markers:HashSet<Marker>(),showPOI: false, scrollEnabled: false);
      add(UpdateMap(settings: settings));
    }
    if (event is ShowDestinationMarker){
      HashSet<Marker> markers = HashSet<Marker>();
      markers.add(event.marker);
      add(UpdateMap(settings: settings.copyWith(markers: markers)));
    }
    if (event is UpdateMap) {
      yield MapSettingsReady(settings: event.settings);
    }
  }
}
