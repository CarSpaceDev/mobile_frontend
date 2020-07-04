import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;

String _mapStyle;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  Marker marker;
  Location location = Location();
  Set<Marker> _markers = HashSet<Marker>();
  BitmapDescriptor _markerIcon;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    location.onLocationChanged.listen((location) async {
      if (_markers.length > 1) {
        print("ClearingMarkers");
        _markers.clear();
      }
      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId("0"),
              position: LatLng(location.latitude, location.longitude),
              icon: _markerIcon,
              onTap: () {
                print("SomeCallback");
              }),
        );
      });
      mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 18.0,
          ),
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      mapController.setMapStyle(_mapStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(1, 1),
                zoom: 16.0,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }

  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
  }
}
