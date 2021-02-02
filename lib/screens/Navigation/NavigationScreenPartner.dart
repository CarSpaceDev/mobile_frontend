import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/services/MqttService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../../serviceLocator.dart';

class NavigationScreenPartner extends StatefulWidget {
  final LatLng partnerLoc;
  final String reservationId;
  NavigationScreenPartner({@required this.partnerLoc, @required this.reservationId});
  @override
  _NavigationScreenPartnerState createState() => _NavigationScreenPartnerState(this.partnerLoc, this.reservationId);
}

class _NavigationScreenPartnerState extends State<NavigationScreenPartner> {
  LatLng partnerLoc;
  final String reservationId;
  LatLng tempPartnerLoc;
  LatLng driverLoc;
  LatLng tempDriverLoc;
  String _mapStyle;
  Set<Marker> _markers = HashSet<Marker>();
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  GoogleMapController mapController;
  LatLngBounds mapBounds;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> mqttUpdates;
  _NavigationScreenPartnerState(this.partnerLoc, this.reservationId);

  @override
  void initState() {
    tempPartnerLoc = LatLng(10.258173349737774, 123.8179593690133);
    partnerLoc = tempPartnerLoc;
    tempDriverLoc = LatLng(10.269003129465927, 123.81134209897097);
    driverLoc = tempDriverLoc;
    _setMapBounds();
    _setMarkerIcon();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    mqttUpdates = locator<MqttService>().client.updates.listen(handleMessage);
    locator<MqttService>().subscribe(reservationId);
    super.initState();
  }

  _setMapBounds() {
    double swLat = 0;
    double swLng = 0;
    double neLat = 0;
    double neLng = 0;
    if (partnerLoc.latitude <= driverLoc.latitude) {
      swLat = partnerLoc.latitude;
      neLat = driverLoc.latitude;
    } else {
      swLat = driverLoc.latitude;
      neLat = partnerLoc.latitude;
    }
    if (partnerLoc.longitude <= driverLoc.longitude) {
      swLng = partnerLoc.longitude;
      neLng = driverLoc.longitude;
    } else {
      swLng = driverLoc.longitude;
      neLng = partnerLoc.longitude;
    }
    this.mapBounds = LatLngBounds(southwest: LatLng(swLat, swLng), northeast: LatLng(neLat, neLng));
  }

  @override
  void dispose() {
    locator<MqttService>().unSubscribe(reservationId);
    mqttUpdates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      appBar: AppBar(
          backgroundColor: themeData.primaryColor,
          brightness: Brightness.dark,
          title: Text("Reservation"),
          centerTitle: true,
          leading: Builder(
            builder: (context) => InkWell(
              onTap: () {},
              child: Container(child: Icon(Icons.menu)),
            ),
          ),
          actions: null,
          bottom: null),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: GoogleMap(
                cameraTargetBounds: CameraTargetBounds(mapBounds),
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: partnerLoc,
                  zoom: 15.0,
                ),
                markers: _markers,
              ),
            ),
            Expanded(
              child: Container(
                  color: Colors.white,
                  child: Text((Geolocator.distanceBetween(driverLoc.latitude, driverLoc.longitude, partnerLoc.latitude, partnerLoc.longitude) / 1000)
                          .toStringAsFixed(2) +
                      " km")),
            ),
          ],
        ),
      ),
    );
  }

  handleMessage(List<MqttReceivedMessage<MqttMessage>> v) {
    MqttPublishMessage recMess = v[0].payload;
    String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    var payload = jsonDecode(pt);
    print(payload);
    // print(payload["type"]);
    // print(payload["destination"]);
    // print(payload["message"]);

    // this.setState(() {
    //   if (payload["type"] == 0) {
    //     messages.insert(0, "Message to be sent to ${payload['destination']}:\n ${payload["message"]}");
    //     if (payload['destination'] != null && payload['message'] != null) {
    //       print('Sending a message');
    //       _sendMessage(dest: payload["destination"], smsContent: payload["message"]);
    //     }
    //   } else {
    //     messages.insert(0, "Unformatted message received $payload");
    //   }
    // });
  }

  void _setMarkerIcon() async {
    List<BitmapDescriptor> markerFiles = [];
    markerFiles = await Future.wait([
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png'),
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png'),
    ]);
    _lotIcon = markerFiles[0];
    _driverIcon = markerFiles[1];
    _markers.add(Marker(markerId: MarkerId("Lot"), onTap: () {}, icon: _lotIcon, position: partnerLoc));
    _markers.add(Marker(markerId: MarkerId("Driver"), onTap: () {}, icon: _driverIcon, position: driverLoc));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      mapController.setMapStyle(_mapStyle);
      mapController.moveCamera(CameraUpdate.newLatLngBounds(mapBounds, 90));
    });
  }
}
