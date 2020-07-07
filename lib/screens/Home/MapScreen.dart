import 'package:carspace/services/DevTools.dart';
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
  bool viewCentered;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    location.onLocationChanged.listen((location) async {
      devLog("LocationUpdate","Updating location : ["+location.latitude.toString()+','+location.longitude.toString()+']');
      setState(() {
        _markers.clear();
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
      if (viewCentered==null) {
        devLog("ViewNotCentered","view is not centered");
        mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 16.0,
            ),
          ),
        );
        setState(() {
          viewCentered = true;
        });
      }
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
    return Container(
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
    );
  }

  void _setMarkerIcon() async {
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
  }
}
