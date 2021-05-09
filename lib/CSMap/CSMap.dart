
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/blocs/timings/timings_bloc.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'bloc/map_bloc.dart';

class CSMap extends StatefulWidget {
  CSMap();
  @override
  _CSMapState createState() => _CSMapState();
}

class _CSMapState extends State<CSMap> {
  CSPosition currentPosition;
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
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(state.position.latitude, state.position.longitude), zoom: zoom)));
            setState(() {
            });
          }
        }),
        BlocListener<MapBloc, MapState>(listener: (BuildContext context, state) {
          if (state is MapSettingsReady) {
            mapController?.setMapStyle(state.settings.showPOI ? state.settings.mapStylePOI : state.settings.mapStyle);
            setState(() {
            });
          }
        }),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (BuildContext context, state) {
          if (state is MapSettingsReady) {
            return GoogleMap(
              onCameraIdle: () {
                setState(() {});
              },
              onCameraMove: (CameraPosition camera) {
                zoom = camera.zoom;
              },
              myLocationEnabled: state.settings.showSelfLocation,
              myLocationButtonEnabled: state.settings.showSelfLocation,
              scrollGesturesEnabled: state.settings.scrollEnabled,
              mapToolbarEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                mapController = controller;
                mapController?.setMapStyle(state.settings.showPOI ? state.settings.mapStylePOI : state.settings.mapStyle);
                context
                    .read<TimingsBloc>()
                    .add(EndTest(type: TimingsType.MapLoad));
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(context.bloc<GeolocationBloc>().lastKnownPosition.latitude, context.bloc<GeolocationBloc>().lastKnownPosition.longitude),
                zoom: zoom,
              ),
              markers: state.settings.markers,
            );
          }
          else return LoadingFullScreenWidget(prompt:"LOADING MAP");
        },
      ),
    );
  }
}
