import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/model/DriverReservation.dart';
import 'package:carspace/model/Enums.dart';
import 'package:carspace/reusable/RatingAndFeedback.dart';
import 'package:carspace/screens/Navigation/DriverNavigationService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/navigation.dart';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenScreenState createState() => _ReservationScreenScreenState();
}

class _ReservationScreenScreenState extends State<ReservationScreen> {
  List<DriverReservation> _reservationData;
  var _uid;
  var _driverName;
  bool _fetching;
  @override
  void initState() {
    _fetching = true;
    getUserReservations();
    super.initState();
  }

  void getUserReservations() async {
    await locator<ApiService>().getUserReservation(uid: locator<AuthService>().currentUser().uid).then((data) {
      if (data.body.runtimeType != String && data.statusCode == 200) {
        List<DriverReservation> result = [];
        List.from(data.body).forEach((reservation) {
          result.add(DriverReservation.fromJson(reservation));
        });
        result.sort((DriverReservation a, DriverReservation b) {
          if (a.status == ReservationStatus.BOOKED || a.status == ReservationStatus.RESERVED)
            return -1;
          else if (a.status == b.status)
            return 0;
          else
            return 1;
        });
        setState(() {
          _reservationData = result;
          _fetching = false;
        });
      } else {
        setState(() {
          _reservationData = [];
          _fetching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text('Reservations'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _fetching = true;
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
            padding: const EdgeInsets.all(16),
            child: Card(
              color: (_reservationData[index].status == ReservationStatus.BOOKED) ? Colors.white : Colors.grey[200],
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
                                imageUrl: _reservationData[index].lotImage,
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
                                    TextSpan(text: 'Type : ', style: TextStyle(color: Colors.grey)),
                                    TextSpan(
                                        text: (_reservationData[index].type == ReservationType.BOOKING)
                                            ? "Booking"
                                            : "Reservation")
                                  ]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: RichText(
                                  text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                    TextSpan(text: 'Status : ', style: TextStyle(color: Colors.grey)),
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
            ));
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
                    _reservationData[index].status == ReservationStatus.BOOKED
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    DriverNavigationService(reservationId: _reservationData[index].reservationId)
                                        .navigateViaMapBox(_reservationData[index].coordinates);
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
                                    onTheWay(this._uid, this._driverName, _reservationData[index].vehicleId,
                                        _reservationData[index].lotAddress, _reservationData[index].partnerId);
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
                                    arrived(this._uid, this._driverName, _reservationData[index].vehicleId,
                                        _reservationData[index].lotAddress, _reservationData[index].partnerId);
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
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (_reservationData[index].type == ReservationType.BOOKING)
                                      markAsComplete(
                                          _uid,
                                          _reservationData[index].lotId,
                                          _reservationData[index].vehicleId,
                                          _reservationData[index].reservationId,
                                          _reservationData[index].lotAddress,
                                          _reservationData[index].partnerId);
                                    else
                                      markAsCompleteV2(
                                          _uid,
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
                                        'Mark as Complete',
                                        style: TextStyle(color: Colors.redAccent),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _reservationData[index].userRating == false
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          rating(_reservationData[index], _uid);
                                        },
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.car_repair,
                                              color: Colors.blueAccent,
                                            ),
                                            Text('Give rating and feedback', style: TextStyle(color: Colors.blueAccent))
                                          ],
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.car_repair,
                                              color: Colors.blueAccent,
                                            ),
                                            Text('You have already rated and sent your feedback',
                                                style: TextStyle(color: Colors.blueAccent))
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

  onTheWay(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "driverName": driverName,
      "vehicleId": vehicleId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().notifyOnTheWay(body).then((data) {
      showMessage("Lot owner notified");
    });
  }

  arrived(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "driverName": driverName,
      "vehicleId": vehicleId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().notifyArrived(body).then((data) {
      showMessage("Lot owner notified");
    });
  }

  rating(reservationData, userId) async {
    var userId = locator<AuthService>().currentUser().uid;
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
                    child: RatingAndFeedback(reservationData, userId, 0),
                  ),
                ),
              ),
            ));
  }

  showMessage(String v) {
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
