import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/DriverReservation.dart';
import 'package:carspace/screens/Navigation/DriverNavigationService.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../navigation.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenScreenState createState() => _ReservationScreenScreenState();
}

class _ReservationScreenScreenState extends State<ReservationScreen> {
  List<DriverReservation> _reservationData;
  var _partnerAccess;
  var _uid;
  var _driverName;
  bool _fetching;
  @override
  void initState() {
    super.initState();
    _fetching = true;
    _initPartnerAccess();
    getUserReservations();
  }

  _initPartnerAccess() async {
    var userData = locator<AuthService>().currentUser();
    var uid = userData.uid;
    _driverName = userData.displayName;

    await locator<ApiService>().getVerificationStatus(uid: uid).then((data) {
      _uid = uid;
      _partnerAccess = data.body['partnerAccess'];
    });
  }

  void getUserReservations() async {
    await locator<ApiService>().getUserReservations(uid: locator<AuthService>().currentUser().uid).then((data) {
      List<DriverReservation> result = [];
      List.from(data.body).forEach((reservation) {
        result.add(DriverReservation.fromJson(reservation));
      });
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
          title: Text('Reservations'),
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
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: SizedBox(
              height: (_reservationData[index].timeUpdated != _reservationData[index].timeCreated) ? 250 : 225,
              width: 200,
              child: Card(
                color: (_reservationData[index].status == DriverReservationStatus.BOOKED) ? Colors.white : Colors.grey[200],
                elevation: 4.0,
                child: InkWell(
                  onTap: () {
                    _showActionsDialog(index: index);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(_reservationData[index].lotAddress, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                  imageUrl: _reservationData[index].lotImage,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => LinearProgressIndicator(value: downloadProgress.progress),
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
                                      TextSpan(text: (_reservationData[index].type == DriverReservationType.BOOKING) ? "Reservation" : "Recurring")
                                    ]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: RichText(
                                    text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                      TextSpan(text: 'Reservation Status : ', style: TextStyle(color: Colors.grey)),
                                      TextSpan(
                                          text: (_reservationData[index].status == DriverReservationStatus.BOOKED) ? "Active" : "Completed",
                                          style: (_reservationData[index].status == DriverReservationStatus.BOOKED)
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
            ));
      },
    );
  }

  _showActionsDialog({int index}) {
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
                        if (_reservationData[index].status == DriverReservationStatus.BOOKED)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    DriverNavigationService().navigateViaMapBox(_reservationData[index].coordinates, _reservationData[index].reservationId);
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      Text('Navigate to Lot(BETA)', style: TextStyle(color: Colors.blueAccent))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    DriverNavigationService().navigateViaGoogleMaps(_reservationData[index].coordinates);
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.map_outlined,
                                        color: Colors.blueAccent,
                                      ),
                                      Text('Navigate to Lot', style: TextStyle(color: Colors.blueAccent))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    onTheWay(this._uid, this._driverName, _reservationData[index].vehicleId, _reservationData[index].lotAddress,
                                        _reservationData[index].partnerId);
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.chat,
                                        color: Colors.blueAccent,
                                      ),
                                      Text('Notify on the way', style: TextStyle(color: Colors.blueAccent))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    arrived(this._uid, this._driverName, _reservationData[index].vehicleId, _reservationData[index].lotAddress,
                                        _reservationData[index].partnerId);
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.car_repair,
                                        color: Colors.blueAccent,
                                      ),
                                      Text('Notify arrived', style: TextStyle(color: Colors.blueAccent))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  onTheWay(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({"userId": userId, "driverName": driverName, "vehicleId": vehicleId, "lotAddress": lotAddress, "partnerId": partnerId});
    await locator<ApiService>().notifyOnTheWay(body).then((data) {
      showMessage("Lot owner notified");
    });
  }

  arrived(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({"userId": userId, "driverName": driverName, "vehicleId": vehicleId, "lotAddress": lotAddress, "partnerId": partnerId});
    await locator<ApiService>().notifyArrived(body).then((data) {
      showMessage("Lot owner notified");
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
                      style: TextStyle(height: 5, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    locator<NavigationService>().pushNavigateTo(Reservations);
                  },
                  child: Text("Close"))
            ],
          );
        });
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
