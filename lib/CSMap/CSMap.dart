import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class CSMap extends StatefulWidget {
  final MapBloc mapBloc;
  final GeolocationBloc geoBloc;
  CSMap({this.mapBloc, this.geoBloc});
  @override
  _CSMapState createState() => _CSMapState();
}

class _CSMapState extends State<CSMap> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  CSPosition currentPosition;
  Widget csMap;
  GoogleMapController mapController;
  double zoom = 16;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mapBloc == null) {
      mapBloc = MapBloc();
    } else
      mapBloc = widget.mapBloc;
    if (widget.geoBloc == null) {
      geoBloc = GeolocationBloc();
    } else
      geoBloc = widget.geoBloc;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => mapBloc),
        BlocProvider(create: (BuildContext context) => geoBloc)
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GeolocationBloc, GeolocationState>(listener: (BuildContext context, state) {
            // print(state);
            if (state is PositionUpdated) {
              mapController?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: zoom)));
              setState(() {
                currentPosition = state.position;
              });
            }
          }),
          BlocListener<MapBloc, MapState>(listener: (BuildContext context, state) {
            // print(state);
            if (state is MapSettingsReady) {
              print("RFDAJSHKFDLSKDL:");
              print(state.settings.markers);
              setState(() {
              });
            }
          })
        ],
        child: BlocBuilder<MapBloc, MapState>(
          builder: (BuildContext context, state) {
            // print(state);
            if (state is MapInitial) {
              print("Firing Initialize GeoLoc Event");
              geoBloc.add(StartGeolocation());
              print("Firing Init Map Event");
              mapBloc.add(InitializeMapSettings());
            }
            if (state is MapSettingsReady) {
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
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: true,
                    onMapCreated: (GoogleMapController controller) async {
                      mapController = controller;
                      mapController
                          .setMapStyle(state.settings.showPOI ? state.settings.mapStylePOI : state.settings.mapStyle);
                    },
                    initialCameraPosition: currentPosition != null
                        ? CameraPosition(
                            target: LatLng(currentPosition.latitude, currentPosition.longitude),
                            zoom: 15.0,
                          )
                        : CameraPosition(
                            target: LatLng(10.313741830368738, 123.89023728796286),
                            zoom: 15.0,
                          ),
                    markers: state.settings.markers,
                  )
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
