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
  Set<Marker> _markers = HashSet<Marker>();
  String _mapStyle;
  String _mapStylePOI;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;

  MapBloc() : super(MapInitial());

  @override
  Stream<MapState> mapEventToState(
    MapEvent event,
  ) async* {
    if (event is InitializeMap) {
      List<dynamic> result = await Future.wait([
        rootBundle.loadString('assets/mapPOI.txt'),
        rootBundle.loadString('assets/mapStyle.txt'),
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png'),
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png')
      ]);
      _mapStylePOI = result[0];
      _mapStyle = result[1];
      _lotIcon = result[2];
      _driverIcon = result[3];


      yield MapReady(map: csMap);
    }
    if (event is UpdateMap) {
      yield MapReady(map: csMap);
    }
    if (event is UpdateMapPosition) {
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(event.position.latitude, event.position.longitude))));
      }
    }
  }
}
