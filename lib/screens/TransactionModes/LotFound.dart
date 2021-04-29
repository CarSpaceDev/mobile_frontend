import 'package:carspace/CSMap/CSStaticMap.dart';
import 'package:carspace/model/DriverReservation.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/Navigation/DriverNavigationService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class LotFound extends StatefulWidget {
  final Lot lot;
  final String user;
  final int type;
  const LotFound(this.lot, this.user, this.type);
  @override
  _LotFoundState createState() => _LotFoundState();
}

class _LotFoundState extends State<LotFound> {
  var namedDays;
  bool noVehicles = true;
  bool working = false;
  bool recurring = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CSTile(
      borderRadius: 16,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CSText(
            widget.lot.address.toString(),
            textType: TextType.H4,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: AspectRatio(aspectRatio: 2, child: CSStaticMap(position: widget.lot.coordinates)),
          ),
          // LotImageWidget(
          //   url: widget.lot.lotImage,
          // ),
          CSTile(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.type == 0
                        ? CSText(
                            "Php ${widget.lot.pricing.toStringAsFixed(2)}/hr",
                          )
                        : CSText(
                            "Php ${widget.lot.pricePerDay.toStringAsFixed(2)}/day",
                          ),
                    CSText(
                      "${formatDate(DateTime(2020, 1, 1, widget.lot.availableFrom ~/ 100, widget.lot.availableFrom % 100), [
                        H,
                        ":",
                        nn,
                        " ",
                        am
                      ])} to ${formatDate(DateTime(2020, 1, 1, widget.lot.availableTo ~/ 100, widget.lot.availableTo % 100), [
                        H,
                        ":",
                        nn,
                        " ",
                        am
                      ])}",
                    )
                  ],
                ),
                if (widget.type == 1)
                  CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: recurring,
                      onChanged: _recurringChangeValue,
                      title: new Text('Reserve as recurring reservation'),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue),
              ],
            ),
          ),

          if (working) loading(),
          if (!working)
            Row(
              children: [
                Expanded(
                  child: CSTile(
                    onTap: () {
                      Navigator.of(context).pop(1);
                    },
                    borderRadius: 8,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    color: TileColor.Red,
                    child: CSText(
                      'CANCEL',
                      textType: TextType.Button,
                      textColor: TextColor.White,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                ),
                Expanded(
                  child: CSTile(
                    onTap: () {
                      if (widget.type == 0)
                        book();
                      else
                        reserve();
                    },
                    borderRadius: 8,
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    color: TileColor.Green,
                    child: CSText(
                      widget.type == 0 ? 'BOOK' : 'RESERVE',
                      textType: TextType.Button,
                      textColor: TextColor.White,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget loading() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  void _recurringChangeValue(bool value) => setState(() => recurring = value);

  book() async {
    print(widget.lot.pricing);
    var body = ({
      "userId": widget.user,
      "lotId": widget.lot.lotId,
      "partnerId": widget.lot.partnerId,
      "reservationType": 0,
      "lotAddress": widget.lot.address.toString(),
      "lotPrice": widget.lot.pricing
    });
    setState(() {
      working = true;
    });
    locator<ApiService>().bookLot(body).then((value) {
      print(value.body);
      print(value.statusCode);
      Navigator.of(context).pop();
      if (value.body["code"] == 200) {
        locator<NavigationService>().pushReplaceNavigateTo(DashboardRoute);
        DriverReservation dRes = DriverReservation.fromJson(value.body["reservationData"]);
        FirebaseFirestore.instance.collection("reservations").doc(dRes.reservationId).get().then((doc) {
          successfulBooking(Reservation.fromDoc(doc));
        });
      } else {
        PopUp.showError(context: context, title: "INFO", body: "${value.body["message"]}");
      }
    }).catchError((err) {
      print(err);
    });
  }

  reserve() async {
    var reserveType;
    if (recurring == false) {
      reserveType = 0;
    } else {
      reserveType = 1;
    }
    print(widget.lot.pricePerDay);
    var body = ({
      "userId": widget.user,
      "lotId": widget.lot.lotId,
      "partnerId": widget.lot.partnerId,
      "reservationType": 1,
      "lotAddress": widget.lot.address.toString(),
      "lotPrice": widget.lot.pricePerDay
    });
    setState(() {
      working = true;
    });
    await locator<ApiService>().reserveLot(reserveType, body).then((value) {
      print(value.body);
      print(value.statusCode);
      setState(() {
        working = false;
      });
      // Navigator.of(context).pop();
      if (value.body["code"] == 200) {
        locator<NavigationService>().pushReplaceNavigateTo(DashboardRoute);
        DriverReservation dRes = DriverReservation.fromJson(value.body["reservationData"]);
        FirebaseFirestore.instance.collection("reservations").doc(dRes.reservationId).get().then((doc) {
          successfulBooking(Reservation.fromDoc(doc));
        });
      } else {
        PopUp.showError(context: context, title: "INFO", body: "${value.body["message"]}");
      }
    }).catchError((err) {
      print(err);
    });
  }

  successfulBooking(Reservation v) {
    PopupNotifications.showNotificationDialog(
      context,
      child: CSTile(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            ),
            CSText(
              "Lot booked",
              textAlign: TextAlign.center,
            ),
            TextButton.icon(
                onPressed: () {
                  Navigator.of(locator<NavigationService>().navigatorKey.currentContext).pop(null);
                  locator<ApiService>().notifyOnTheWay({
                    "userId": widget.user,
                    "lotAddress": widget.lot.address.toString(),
                    "partnerId": widget.lot.partnerId
                  });
                  DriverNavigationService(reservation: v).navigateViaMapBox();
                },
                icon: Icon(Icons.map_outlined),
                label: Text("Navigate To Lot")),
          ],
        ),
      ),
    );
  }
}
