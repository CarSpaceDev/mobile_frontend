import 'dart:collection';

import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class CSMap extends StatefulWidget {
  CSMap();
  @override
  _CSMapState createState() => _CSMapState();
}

class _CSMapState extends State<CSMap> {
  CSPosition currentPosition;
  MapSettings settings;
  Widget csMap;
  GoogleMapController mapController;
  double zoom = 16;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GeolocationBloc, GeolocationState>(listener: (BuildContext context, state) {
          if (state is PositionUpdated) {
            print("Screen focus updated");
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: zoom)));
            setState(() {
              currentPosition = state.position;
            });
          }
        }),
        BlocListener<MapBloc, MapState>(listener: (BuildContext context, state) {
          if (state is MapSettingsReady) {
            print("UPDATING MAP");
            var markers = HashSet<Marker>();
            markers.add(Marker(
                markerId: MarkerId("DRIVER"),
                icon: state.settings.driverIcon,
                position: LatLng(currentPosition.latitude, currentPosition.longitude)));
            if (state.settings.markers.isEmpty) {
              MapSettings temp = state.settings.copyWith(markers: markers);
              setState(() {
                settings = temp;
              });
            } else {
              setState(() {
                settings = state.settings;
              });
            }
          }
        })
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (BuildContext context, state) {
          if (state is MapInitial) {
            print("Firing Initialize GeoLoc Event");
            currentPosition = context.bloc<GeolocationBloc>().lastKnownPosition;
            context.bloc<GeolocationBloc>().add(StartGeolocation());
            print("Firing Init Map Event");
            context.bloc<MapBloc>().add(InitializeMapSettings());
          }
          if (state is MapSettingsReady) {
            if (settings == null) settings = state.settings;
            return Stack(
              children: [
                GoogleMap(
                  onCameraIdle: () {
                    setState(() {});
                    print("CurrentZoomLevel: $zoom");
                  },
                  onCameraMove: (CameraPosition camera) {
                    zoom = camera.zoom;
                  },
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: settings.scrollEnabled,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) async {
                    mapController = controller;
                    mapController.setMapStyle(settings.showPOI ? settings.mapStylePOI : settings.mapStyle);
                  },
                  initialCameraPosition: currentPosition != null
                      ? CameraPosition(
                          target: LatLng(currentPosition.latitude, currentPosition.longitude),
                          zoom: zoom,
                        )
                      : CameraPosition(
                          target: LatLng(10.313741830368738, 123.89023728796286),
                          zoom: zoom,
                        ),
                  markers: settings.markers,
                )
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
