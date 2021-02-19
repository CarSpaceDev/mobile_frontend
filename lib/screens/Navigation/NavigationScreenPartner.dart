import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/PartnerReservation.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/MqttService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shimmer/shimmer.dart';

import '../../serviceLocator.dart';

class NavigationScreenPartner extends StatefulWidget {
  final LatLng partnerLoc;
  final String reservationId;
  final PartnerReservation reservation;
  NavigationScreenPartner(
      {@required this.partnerLoc,
      @required this.reservationId,
      @required this.reservation});
  @override
  _NavigationScreenPartnerState createState() => _NavigationScreenPartnerState(
      this.partnerLoc, this.reservationId, this.reservation);
}

class _NavigationScreenPartnerState extends State<NavigationScreenPartner> {
  final LatLng partnerLoc;
  final String reservationId;
  final PartnerReservation reservationData;
  LatLng driverLoc;
  String _mapStyle;
  double distanceRemaining;
  double durationRemaining;
  Set<Marker> _markers = HashSet<Marker>();
  Marker lotMarker;
  Marker driverMarker;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  GoogleMapController mapController;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>> mqttUpdates;
  _NavigationScreenPartnerState(
      this.partnerLoc, this.reservationId, this.reservationData);

  @override
  void initState() {
    print(partnerLoc.toJson());
    _setMarkerIcon();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    locator<MqttService>().subscribe(reservationId);
    mqttUpdates = locator<MqttService>().client.updates.listen(handleMessage);
    super.initState();
  }

  LatLngBounds _getMapBounds() {
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
    return LatLngBounds(
        southwest: LatLng(swLat, swLng), northeast: LatLng(neLat, neLng));
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
        bottomNavigationBar: BottomAppBar(
          child: FlatButton(
            color: Color(0xff6200EE),
            onPressed: () {
              markAsComplete(
                  widget.reservation.driverId,
                  widget.reservation.lotId,
                  widget.reservation.vehicleId,
                  widget.reservation.reservationId,
                  widget.reservation.lotAddress,
                  widget.reservation.partnerId);
            },
            child: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.green,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                child: Center(
                    child: Text("Mark as complete",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ),
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
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            child: Container(
                color: themeData.primaryColor,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text("${widget.reservation.lotAddress}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                )),
                          ),
                        ]),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child:
                              Text("Driver: ${widget.reservation.displayName}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  )),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child:
                              Text("Vehicle: ${widget.reservation.vehicleId} ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  )),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.74,
            child: GoogleMap(
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              zoomControlsEnabled: true,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: partnerLoc,
                zoom: 15.0,
              ),
              markers: _markers,
            ),
          ),
        ])));
  }

  markAsComplete(String userId, String lotId, String vehicleId,
      String reservationId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().markAsComplete(body).then((data) {
      showMessage(data.body);
    });
  }

  showMessage(dynamic v) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      "$v",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  String getDistanceBetween() {
    if (driverLoc == null)
      return "unknown";
    else
      return (Geolocator.distanceBetween(
                  driverLoc.latitude,
                  driverLoc.longitude,
                  partnerLoc.latitude,
                  partnerLoc.longitude) /
              1000)
          .toStringAsFixed(10);
  }

  handleMessage(List<MqttReceivedMessage<MqttMessage>> v) {
    MqttPublishMessage recMess = v[0].payload;
    String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    var payload = jsonDecode(pt);
    print(payload);
    setState(() {
      distanceRemaining = payload["distanceRemaining"] != null
          ? payload["distanceRemaining"]
          : null;
      durationRemaining = payload["durationRemaining"] != null
          ? payload["durationRemaining"]
          : null;
      driverLoc = LatLng(payload["latitude"], payload["longitude"]);
      driverMarker = Marker(
          markerId: MarkerId("Driver"),
          onTap: () {},
          icon: _driverIcon,
          position: driverLoc);
      _markers = Set.from([lotMarker, driverMarker]);
      mapController
          .moveCamera(CameraUpdate.newLatLngBounds(_getMapBounds(), 90));
    });
  }

  void _setMarkerIcon() async {
    List<BitmapDescriptor> markerFiles = [];
    markerFiles = await Future.wait([
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)),
          'assets/launcher_icon/pushpin.png'),
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)),
          'assets/launcher_icon/driver.png'),
    ]);
    _lotIcon = markerFiles[0];
    _driverIcon = markerFiles[1];
    lotMarker = Marker(
        markerId: MarkerId("Lot"),
        onTap: () {},
        icon: _lotIcon,
        position: partnerLoc);
    _markers.add(lotMarker);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      mapController.setMapStyle(_mapStyle);
    });
  }
}
