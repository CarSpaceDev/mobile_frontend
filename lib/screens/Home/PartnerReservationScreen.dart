import 'package:android_intent/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/model/Enums.dart';
import 'package:carspace/model/PartnerReservation.dart';
import 'package:carspace/screens/Navigation/NavigationScreenPartner.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../navigation.dart';

class PartnerReservationScreen extends StatefulWidget {
  @override
  _PartnerReservationScreenScreenState createState() => _PartnerReservationScreenScreenState();
}

class _PartnerReservationScreenScreenState extends State<PartnerReservationScreen> {
  List<PartnerReservation> _reservationData;
  bool _fetching = true;
  @override
  void initState() {
    _fetching = true;
    getUserReservations();
    super.initState();
  }

  void getUserReservations() async {
    locator<ApiService>().getPartnerReservations(uid: locator<AuthService>().currentUser().uid).then((data) {
      List<PartnerReservation> result = [];
      List.from(data.body).forEach((reservation) {
        result.add(PartnerReservation.fromJson(reservation));
      });
      if (result.length > 0) {
        result.sort((PartnerReservation a, PartnerReservation b) {
          if (a.status == ReservationStatus.BOOKED || a.status == ReservationStatus.RESERVED)
            return -1;
          else if (a.status == b.status)
            return 0;
          else
            return 1;
        });
      }
      setState(() {
        _reservationData = result;
        _fetching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Partner Reservations'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _fetching = false;
                  getUserReservations();
                });
              },
            )
          ],
        ),
        body: ((_fetching) || (_reservationData == null)) ? loading() : reservationEntry());
  }

  ListView reservationEntry() {
    return ListView.builder(
      itemCount: _reservationData.length,
      itemBuilder: (BuildContext context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * .9,
          child: Card(
            color: (_reservationData[index].status == ReservationStatus.BOOKED) ? Colors.white : Colors.grey[200],
            elevation: 4.0,
            child: InkWell(
              onTap: () {
                if (_reservationData[index].status != ReservationStatus.COMPLETED)
                  Navigator.pushReplacement(
                      locator<NavigationService>().navigatorKey.currentContext,
                      MaterialPageRoute(
                          builder: (context) => NavigationScreenPartner(
                              partnerLoc: _reservationData[index].coordinates,
                              reservationId: _reservationData[index].reservationId,
                              reservation: _reservationData[index])));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(_reservationData[index].lotAddress,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                imageUrl: _reservationData[index].photoUrl,
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    LinearProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Icon(Icons.error),
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
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Vehicle: ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(text: _reservationData[index].vehicleId)
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'User name: ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(text: _reservationData[index].displayName)
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Contact No.: ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(text: _reservationData[index].phoneNumber)
                                  ]),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(vertical: 4.0),
                              //   child: RichText(
                              //     text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                              //       TextSpan(text: 'Email Address: ', style: TextStyle(color: Colors.grey)),
                              //       TextSpan(text: _reservationData[index].emailAddress)
                              //     ]),
                              //   ),
                              // ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Date Placed: ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(text: _reservationData[index].dateCreated)
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Time Placed: ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(text: _reservationData[index].timeCreated)
                                  ]),
                                ),
                              ),
                              if (_reservationData[index].dateUpdated != _reservationData[index].dateCreated)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                      TextSpan(text: 'Date Exited: ', style: TextStyle(color: Colors.grey)),
                                      TextSpan(text: _reservationData[index].dateUpdated)
                                    ]),
                                  ),
                                ),
                              if (_reservationData[index].timeUpdated != _reservationData[index].timeCreated)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                      TextSpan(text: 'Time Exited: ', style: TextStyle(color: Colors.grey)),
                                      TextSpan(text: _reservationData[index].timeUpdated)
                                    ]),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Reservation Type : ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(
                                        text: (_reservationData[index].type == ReservationType.BOOKING)
                                            ? "Reservation"
                                            : "Recurring")
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Reservation Status : ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(
                                        text: (_reservationData[index].status == ReservationStatus.BOOKED)
                                            ? "Active"
                                            : "Completed",
                                        style: (_reservationData[index].status == ReservationStatus.BOOKED)
                                            ? TextStyle(color: Colors.green[400])
                                            : TextStyle(color: Colors.deepOrange[400])),
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
          ),
        );
      },
    );
  }

  _showActionsDialog({int index}) {
    if (_reservationData[index].status != ReservationStatus.COMPLETED)
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          markAsComplete(
                              _reservationData[index].driverId,
                              _reservationData[index].lotId,
                              _reservationData[index].vehicleId,
                              _reservationData[index].reservationId,
                              _reservationData[index].lotAddress,
                              _reservationData[index].partnerId);
                        },
                        child: Column(
                          children: [
                            Icon(Icons.check, color: Colors.redAccent),
                            Text(
                              'Mark as Completed',
                              style: TextStyle(color: Colors.redAccent),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              locator<NavigationService>().navigatorKey.currentContext,
                              MaterialPageRoute(
                                  builder: (context) => NavigationScreenPartner(
                                      partnerLoc: _reservationData[index].coordinates,
                                      reservationId: _reservationData[index].reservationId)));
                        },
                        child: Column(
                          children: [
                            Icon(Icons.map_outlined, color: Colors.redAccent),
                            Text(
                              'Track Progress',
                              style: TextStyle(color: Colors.redAccent),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    else
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: Text("This transaction has been completed")),
            ),
          ),
        ),
      );
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
                    Navigator.pop(context);
                  },
                  child: Text("Close"))
            ],
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
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        Text(
          "Loading",
          style: TextStyle(color: Theme.of(context).primaryColor),
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
