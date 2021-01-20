import 'package:android_intent/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../navigation.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenScreenState createState() =>
      _ReservationScreenScreenState();
}

class _ReservationScreenScreenState extends State<ReservationScreen> {
  var _reservationData;
  var _partnerAccess;
  bool _fetching;
  @override
  void initState() {
    super.initState();
    _fetching = true;
    _initPartnerAccess();
    getUserReservations();
  }

  _initPartnerAccess() async {
    var uid = locator<AuthService>().currentUser().uid;
    await locator<ApiService>().getVerificationStatus(uid: uid).then((data) {
      _partnerAccess = data.body['partnerAccess'];
    });
  }

  void getUserReservations() async {
    await locator<ApiService>()
        .getUserReservations(uid: locator<AuthService>().currentUser().uid)
        .then((data) {
      _reservationData = data.body;
      setState(() {
        _fetching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reservations'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              locator<NavigationService>().goBack();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
              },
            )
          ],
        ),
        body: ((_fetching) || (_reservationData == null))
            ? loading()
            : reservationEntry());
  }

  ListView reservationEntry() {
    return ListView.builder(
      itemCount: _reservationData.length,
      itemBuilder: (BuildContext context, index) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: SizedBox(
              height: (_reservationData[index]['timeUpdated'] !=
                      _reservationData[index]['timeCreated'])
                  ? 250
                  : 225,
              width: 200,
              child: Card(
                color: (_reservationData[index]['reservationStatus'] == 1)
                    ? Colors.white
                    : Colors.grey[200],
                elevation: 4.0,
                child: InkWell(
                  onTap: () {
                    _showActionsDialog(index: index);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 8.0, right: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(_reservationData[index]['lotAddress'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  imageUrl: _reservationData[index]['lotImage'],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          LinearProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Vehicle: ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          TextSpan(
                                              text: _reservationData[index]
                                                  ['vehicleId'])
                                        ]),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Date Placed: ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          TextSpan(
                                              text: _reservationData[index]
                                                  ['dateCreated'])
                                        ]),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Time Placed: ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          TextSpan(
                                              text: _reservationData[index]
                                                  ['timeCreated'])
                                        ]),
                                  ),
                                ),
                                if (_reservationData[index]['dateUpdated'] !=
                                    _reservationData[index]['dateCreated'])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Date Exited: ',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            TextSpan(
                                                text: _reservationData[index]
                                                    ['dateUpdated'])
                                          ]),
                                    ),
                                  ),
                                if (_reservationData[index]['timeUpdated'] !=
                                    _reservationData[index]['timeCreated'])
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Time Exited: ',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                            TextSpan(
                                                text: _reservationData[index]
                                                    ['timeUpdated'])
                                          ]),
                                    ),
                                  ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Reservation Type : ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          TextSpan(
                                              text: (_reservationData[index]
                                                          ['reservationType'] ==
                                                      1)
                                                  ? "Reservation"
                                                  : "Recurring")
                                        ]),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Reservation Status : ',
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          TextSpan(
                                              text: (_reservationData[index][
                                                          'reservationStatus'] ==
                                                      1)
                                                  ? "Active"
                                                  : "Completed",
                                              style: (_reservationData[index][
                                                          'reservationStatus'] ==
                                                      1)
                                                  ? TextStyle(
                                                      color: Colors.green[400])
                                                  : TextStyle(
                                                      color: Colors
                                                          .deepOrange[400])),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  _showActionsDialog({int index}) {
    return showDialog(
        context: context,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reservationData[index]['reservationStatus'] == 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                navigateViaGoogleMaps(
                                    _reservationData[index]['g']['geopoint']
                                        ['_latitude'],
                                    _reservationData[index]['g']['geopoint']
                                        ['_longitude']);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                  Text('Navigate to Lot',
                                      style:
                                          TextStyle(color: Colors.blueAccent))
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  void showError({@required String error}) {
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
                        Icons.announcement,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget loading() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: themeData.primaryColor,
                ),
              ),
            ),
          ],
        ),
        Text(
          "Loading",
          style: TextStyle(color: themeData.primaryColor),
        )
      ],
    );
  }
}

navigateViaGoogleMaps(double lat, double lng) {
  final AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('google.navigation:q=$lat,$lng'),
      package: 'com.google.android.apps.maps');
  intent.launch();
}

class ViewReservedLot extends StatefulWidget {
  final lotData;
  final isPartner;
  const ViewReservedLot(this.lotData, this.isPartner);

  @override
  _ViewReservedLotState createState() => _ViewReservedLotState();
}

class _ViewReservedLotState extends State<ViewReservedLot> {
  var lotData;
  bool isPartner = false;

  @override
  void initState() {
    super.initState();
    lotData = widget.lotData;
    isPartner = widget.isPartner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
