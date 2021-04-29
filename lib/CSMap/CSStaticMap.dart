import 'dart:collection';

import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'bloc/map_bloc.dart';

class CSStaticMap extends StatefulWidget {
  final CSPosition position;
  CSStaticMap({this.position});
  @override
  _CSStaticMapState createState() => _CSStaticMapState();
}

class _CSStaticMapState extends State<CSStaticMap> {
  double zoom = 16;
  GoogleMapController mapController;
  HashSet<Marker> markers = HashSet<Marker>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => new MapBloc(),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (BuildContext context, state) {
          if (state is MapInitial) {
            context.bloc<MapBloc>().add(InitializeStaticMapSettings(position: widget.position));
          }
          if (state is MapSettingsReady) {
            return GoogleMap(
              onCameraMove: (CameraPosition camera) {
                zoom = camera.zoom;
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                mapController = controller;
                mapController?.setMapStyle(state.settings.mapStyle);
              },
              initialCameraPosition: CameraPosition(
                target: widget.position.toLatLng(),
                zoom: zoom,
              ),
              markers: state.settings.markers,
            );
          } else
            return LoadingFullScreenWidget(prompt: "LOADING MAP");
        },
      ),
    );
  }
}
