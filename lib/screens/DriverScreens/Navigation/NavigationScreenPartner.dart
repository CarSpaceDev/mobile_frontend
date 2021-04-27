import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:carspace/model/Enums.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/RatingAndFeedback.dart';
import 'package:carspace/reusable/UserDisplayNameWidget.dart';
import 'package:carspace/screens/DriverScreens/HomeDashboard.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/MqttService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shimmer/shimmer.dart';

class NavigationScreenPartner extends StatefulWidget {
  final Reservation reservation;
  NavigationScreenPartner({@required this.reservation});
  @override
  _NavigationScreenPartnerState createState() => _NavigationScreenPartnerState();
}

class _NavigationScreenPartnerState extends State<NavigationScreenPartner> {
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
  @override
  void initState() {
    _setMarkerIcon();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    locator<MqttService>().subscribe(widget.reservation.uid);
    mqttUpdates = locator<MqttService>().client.updates.listen(handleMessage);
    super.initState();
  }

  LatLngBounds _getMapBounds() {
    double swLat = 0;
    double swLng = 0;
    double neLat = 0;
    double neLng = 0;
    if (widget.reservation.position.latitude <= driverLoc.latitude) {
      swLat = widget.reservation.position.latitude;
      neLat = driverLoc.latitude;
    } else {
      swLat = driverLoc.latitude;
      neLat = widget.reservation.position.latitude;
    }
    if (widget.reservation.position.longitude <= driverLoc.longitude) {
      swLng = widget.reservation.position.longitude;
      neLng = driverLoc.longitude;
    } else {
      swLng = driverLoc.longitude;
      neLng = widget.reservation.position.longitude;
    }
    return LatLngBounds(southwest: LatLng(swLat, swLng), northeast: LatLng(neLat, neLng));
  }

  @override
  void dispose() {
    locator<MqttService>().unSubscribe(widget.reservation.uid);
    mqttUpdates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        brightness: Brightness.dark,
        title: Text("Reservation"),
        centerTitle: true,
      ),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        CSTile(
          margin: EdgeInsets.zero,
          color: TileColor.Secondary,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CSText(
                "${widget.reservation.lotAddress}",
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  UserDisplayNameWidget(uid: widget.reservation.userId),
                  CSText(
                    "Vehicle: ${widget.reservation.vehicleId} ",
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: true,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.reservation.position.toLatLng(),
              zoom: 15.0,
            ),
            markers: _markers,
          ),
        ),
        CSTile(
          color: TileColor.Secondary,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.symmetric(vertical: 24),
          onTap: () {
            if (widget.reservation.reservationStatus ==
                ReservationStatus.Active) if (this.widget.reservation.reservationType == ReservationType.Booking)
              markAsComplete(widget.reservation.userId, widget.reservation.lotId, widget.reservation.vehicleId,
                  widget.reservation.uid, widget.reservation.lotAddress, widget.reservation.partnerId);
            else {
              markAsCompleteV2(widget.reservation.userId, widget.reservation.lotId, widget.reservation.vehicleId,
                  widget.reservation.uid, widget.reservation.lotAddress, widget.reservation.partnerId);
            }
            else {
              if (!this.widget.reservation.partnerRating) {
                rating(this.widget.reservation);
              } else {
                showMessage("Rating already provided");
              }
            }
          },
          child: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.green,
            child: this.widget.reservation.reservationStatus == ReservationStatus.Active
                ? Text("Mark as complete",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                : Text("Rate Driver", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        )
      ]),
    );
  }

  rating(reservationData) async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => Dialog(
              insetPadding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .1, horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: new SizedBox(
                height: 250,
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: RatingAndFeedback(reservationData, reservationData.driverId, 1),
                  ),
                ),
              ),
            ));
  }

  markAsComplete(
      String userId, String lotId, String vehicleId, String reservationId, String lotAddress, String partnerId) async {
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

  markAsCompleteV2(
      String userId, String lotId, String vehicleId, String reservationId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().markAsCompleteV2(body).then((data) {
      showMessage(data.body);
    });
  }

  showMessage(dynamic v) {
    showDialog(
        context: locator<NavigationService>().navigatorKey.currentContext,
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
                    locator<NavigationService>().pushReplaceNavigateTo(PartnerReservations);
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
      return (Geolocator.distanceBetween(driverLoc.latitude, driverLoc.longitude, widget.reservation.position.latitude,
                  widget.reservation.position.longitude) /
              1000)
          .toStringAsFixed(10);
  }

  handleMessage(List<MqttReceivedMessage<MqttMessage>> v) {
    MqttPublishMessage recMess = v[0].payload;
    String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    var payload = jsonDecode(pt);
    setState(() {
      distanceRemaining = payload["distanceRemaining"] != null ? payload["distanceRemaining"] : null;
      durationRemaining = payload["durationRemaining"] != null ? payload["durationRemaining"] : null;
      driverLoc = LatLng(payload["latitude"], payload["longitude"]);
      driverMarker = Marker(markerId: MarkerId("Driver"), onTap: () {}, icon: _driverIcon, position: driverLoc);
      _markers = Set.from([lotMarker, driverMarker]);
      mapController.moveCamera(CameraUpdate.newLatLngBounds(_getMapBounds(), 90));
    });
  }

  void _setMarkerIcon() async {
    List<BitmapDescriptor> markerFiles = [];
    markerFiles = await Future.wait([
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png'),
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png'),
    ]);
    _lotIcon = markerFiles[0];
    _driverIcon = markerFiles[1];
    lotMarker = Marker(
        markerId: MarkerId("Lot"), onTap: () {}, icon: _lotIcon, position: widget.reservation.position.toLatLng());
    _markers.add(lotMarker);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      mapController.setMapStyle(_mapStyle);
    });
  }
}
