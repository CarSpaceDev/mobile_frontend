import 'package:android_intent/android_intent.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/DriverReservation.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/User.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class LotFound extends StatefulWidget {
  final Lot lot;
  final Vehicle vehicle;
  final CSUser user;
  const LotFound(this.lot, this.vehicle, this.user);
  @override
  _LotFoundState createState() => _LotFoundState();
}

class _LotFoundState extends State<LotFound> {
  var namedDays;
  bool noVehicles = true;
  bool working = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 8, right: 8, left: 8),
                    child: Text(
                      widget.lot.address.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.lot.lotImage[0],
                        fit: BoxFit.fill,
                        height: 150,
                        width: 250,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Price :\n${widget.lot.pricing}Php / Hour", textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Available from: \n${widget.lot.availableFrom}H to ${widget.lot.availableTo}H", textAlign: TextAlign.center),
                  ),
                ],
              )),
              working
                  ? loading()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(1);
                            },
                            color: themeData.secondaryHeaderColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              width: SizeConfig.widthMultiplier * 50,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FlatButton(
                            onPressed: () {
                              reserve();
                            },
                            color: themeData.secondaryHeaderColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              width: SizeConfig.widthMultiplier * 50,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Book',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lot Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close)),
              ],
            ),
          )),
        ],
      ),
    ));
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: themeData.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  reserve() async {
    var body = ({
      "userId": widget.user.uid,
      "lotId": widget.lot.lotId,
      "partnerId": widget.lot.partnerId,
      "vehicleId": widget.vehicle.plateNumber,
      "reservationType": 1,
      "lotAddress": widget.lot.address.toString()
    });
    setState(() {
      working = true;
    });
    await locator<ApiService>().reserveLot(body).then((value) {
      print(value.body);
      print(value.statusCode);
      Navigator.of(context).pop();
      if (value.body["code"] == 200) {
        successfulBooking(DriverReservation.fromJson(value.body["reservationData"]));
      } else {
        showMessage(value.body["message"]);
      }
    }).catchError((err) {
      print(err);
    });
  }

  navigateViaGoogleMaps(double lat, double lng) {
    final AndroidIntent intent =
        AndroidIntent(action: 'action_view', data: Uri.encodeFull('google.navigation:q=$lat,$lng'), package: 'com.google.android.apps.maps');
    intent.launch();
  }

  successfulBooking(DriverReservation v) {
    print(v.toJson());
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
                      "Lot booked",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(onPressed: Navigator.of(context).pop, child: Text("Close")),
            ],
          );
        });
  }

  void showMessage(dynamic v) {
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
            actions: [FlatButton(onPressed: Navigator.of(context).pop, child: Text("Close"))],
          );
        });
  }
}
