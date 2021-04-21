import 'dart:collection';

import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class CSMap extends StatefulWidget {
  @override
  _CSMapState createState() => _CSMapState();
}

class _CSMapState extends State<CSMap> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  CSPosition currentPosition;
  Widget csMap;
  GoogleMapController mapController;
  Set<Marker> _markers = HashSet<Marker>();
  String _mapStyle;
  String _mapStylePOI;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mapBloc == null) {
      mapBloc = MapBloc();
    }
    if (geoBloc == null) {
      geoBloc = GeolocationBloc();
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => mapBloc),
        BlocProvider(create: (BuildContext context) => geoBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GeolocationBloc, GeolocationState>(listener: (BuildContext context, state) {
            print(state);
            if (state is PositionUpdated) {
              setState(() {
                currentPosition = state.position;
              });
            }
          })
        ],
        child: BlocBuilder<MapBloc, MapState>(
          builder: (BuildContext context, state) {
            print(state);
            if (state is MapInitial) {
              print("Firing Initialize GeoLoc Event");
              geoBloc.add(InitializeGeolocation());
              print("Firing Init Map Event");
              mapBloc.add(InitializeMap());
            }
            if (state is MapReady) {
              return GoogleMap(
                // onCameraMove: _onCameraMove,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  mapController.setMapStyle(_mapStyle);
                  mapBloc.add(UpdateMap());
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(1, 1),
                  zoom: 15.0,
                ),
                markers: _markers,
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
