import 'package:android_intent/android_intent.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class LotFound extends StatefulWidget {
  final lotId;
  final vehicleId;
  final uid;
  const LotFound(this.lotId, this.vehicleId, this.uid);
  @override
  _LotFoundState createState() => _LotFoundState();
}

class _LotFoundState extends State<LotFound> {
  var _vehicleId;
  var _uid;
  var namedDays;
  var _lotData;
  bool dataLoaded = false;
  bool noVehicles = true;

  @override
  void initState() {
    super.initState();
    initData();
    print(_lotData);
  }

  initData() async {
    await locator<ApiService>().getLot(uid: widget.lotId).then((res) async {
      _lotData = res.body;
      setState(() {
        dataLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (dataLoaded)
            ? Container(
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
                              padding: const EdgeInsets.only(
                                  top: 25, bottom: 8, right: 8, left: 8),
                              child: Text(
                                _lotData['address'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  _lotData['lotImage'],
                                  fit: BoxFit.fill,
                                  height: 150,
                                  width: 250,
                                )),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                  "Price :\n${_lotData['pricing']}Php / Hour",
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                  "Available from: \n${_lotData['availableFrom']}H to ${_lotData['availableTo']}H",
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        )),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop(1);
                                },
                                color: themeData.secondaryHeaderColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  width: SizeConfig.widthMultiplier * 50,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.textMultiplier *
                                                    2.5),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  width: SizeConfig.widthMultiplier * 50,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        'Book',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.textMultiplier *
                                                    2.5),
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
                      padding: const EdgeInsets.only(
                          top: 4, left: 4, right: 4, bottom: 20),
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
              )
            : loading());
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

  reserve() async {
    var body = ({
      "userId": widget.uid,
      "lotId": _lotData['lotId'],
      "partnerId": _lotData['partnerId'],
      "vehicleId": widget.vehicleId,
      "reservationType": 1,
      "lotAddress": _lotData['address']
    });
    await locator<ApiService>().reserveLot(body).then((value) {
      Navigator.of(context).pop();
      if (value.body == "Reservation Success") {
        showMessageAndUseIntent("Lot Booked");
      } else {
        showMessage(value.body);
      }
    }).catchError((err) {
      print(err);
    });
  }

  navigateViaGoogleMaps(double lat, double lng) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.navigation:q=$lat,$lng'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  showMessageAndUseIntent(dynamic v) {
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
                      "$v \n",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(context).pop, child: Text("Close")),
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
            actions: [
              FlatButton(
                  onPressed: Navigator.of(context).pop, child: Text("Close"))
            ],
          );
        });
  }
}
