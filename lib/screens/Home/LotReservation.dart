import 'package:android_intent/android_intent.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';


class LotReservation extends StatefulWidget {
  final lotId;
  final double currentBalance;
  const LotReservation(this.lotId, this.currentBalance);
  @override
  _LotReservationState createState() => _LotReservationState();
}

class _LotReservationState extends State<LotReservation> {
  Future<dynamic> _lotData;
  List<Vehicle> vehicles = [];
  var _verificationStatus;
  var _lotId;
  var _partnerId;
  var _userId;
  var namedDays;
  var _fullLotData;
  var selectedVehicle = "No Vehicle Selected";
  bool noVehicles = true;

  @override
  void initState() {
    super.initState();
    _initData();
    populateVehicles();
    _lotData = _getLotData(widget.lotId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(
        children: <Widget>[
          FutureBuilder<dynamic>(
            future: _lotData,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                namedDays = daysToNamedDays(snapshot.data['availableDays']);
                return Column(
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
                            '${snapshot.data['address']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              snapshot.data['lotImage'],
                              fit: BoxFit.fill,
                              height: 150,
                              width: 250,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Rating : \n$_verificationStatus",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              "Price :\n${snapshot.data['pricing']} Php / Hour",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Available Days :\n$namedDays",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              "Available from: \n${snapshot.data['availableFrom']}H - ${snapshot.data['availableTo']}H ",
                              textAlign: TextAlign.center),
                        ),
                        if (!noVehicles)
                          vehiclesPresent()
                        else
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 4, left: 4, bottom: 4),
                            child: Text(
                                "No vehicles on file. Please register a vehicle to reserve a lot ",
                                textAlign: TextAlign.center),
                          ),
                      ],
                    )),
                    if (!noVehicles)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FlatButton(
                              onPressed: () {
                                if (selectedVehicle == "No Vehicle Selected")
                                  _vehicleCheck();
                                else
                                  _reserveButton();
                              },
                              color: Theme.of(context).secondaryHeaderColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                width: SizeConfig.widthMultiplier * 50,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'Next',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              SizeConfig.textMultiplier * 2.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              } else {
                return Container(
                  child: Center(
                      child: Container(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "Loading",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        )
                      ],
                    ),
                  )),
                );
              }
            },
          ),
          Positioned(
              child: Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reserve Lot',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  daysToNamedDays(dynamic data) {
    var numberDays = data;
    var numberToNamed = [];
    var namedToString;
    var namedDays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    if (numberDays.length == 7) {
      return namedToString = 'Everyday';
    } else {
      for (var i = 0; i < numberDays.length; i++) {
        numberToNamed.add(namedDays[numberDays[i]]);
      }
      namedToString = numberToNamed.join(', ').toString();
      return namedToString;
    }
  }

  Future<void> _vehicleCheck() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select a vehicle'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reserveButton() async {
    var choice = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          if (_verificationStatus < 210) {
            return AlertDialog(
              title: Text('Error Proceeding'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'Error proceeding to type selection - please have your account verified'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          } else {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please select type'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Back'),
                  onPressed: () {
                    Navigator.of(context).pop(2);
                  },
                ),
                TextButton(
                  child: Text('Reserve'),
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                ),
                TextButton(
                  child: Text('Recurring'),
                  onPressed: () {
                    Navigator.of(context).pop(0);
                  },
                ),
              ],
            );
          }
        });
    if (choice == 0) {
      var body = ({
        "userId": _userId,
        "lotId": _lotId,
        "partnerId": _partnerId,
        "vehicleId": selectedVehicle,
        "reservationType": 0,
        "lotAddress": _fullLotData['address'],
        "balance": widget.currentBalance,
        "lotPrice" : _fullLotData.pricing
      });
      await locator<ApiService>().bookLot(body).then((value) {
        Navigator.of(context).pop();
        showMessage(value.body);
      }).catchError((err) {
        print(err);
      });
    } else if (choice == 1) {
      var body = ({
        "userId": _userId,
        "lotId": _lotId,
        "partnerId": _partnerId,
        "vehicleId": selectedVehicle,
        "reservationType": 1,
        "lotAddress": _fullLotData['address'],
        "balance": widget.currentBalance,
        "lotPrice" : _fullLotData.pricing
      });
      await locator<ApiService>().bookLot(body).then((value) {
        Navigator.of(context).pop();
        if (value.body == "Reservation Success") {
          showMessageAndUseIntent("Lot Reserved");
        } else {
          showMessage(value.body);
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      print('Back');
    }
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
              FlatButton(
                child: Text("Navigate to Lot"),
                onPressed: () {
                  navigateViaGoogleMaps(
                      _fullLotData['g']['geopoint']['_latitude'],
                      _fullLotData['g']['geopoint']['_longitude']);
                },
              )
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

  Future<dynamic> _getLotData(lotId) async {
    var returnData;
    await locator<ApiService>().getLot(uid: lotId).then((res) async {
      returnData = res.body;
      _lotId = res.body['lotId'];
      _partnerId = res.body['partnerId'];
      _fullLotData = res.body;
    });
    return returnData;
  }

  Future<dynamic> _initData() async {
    var uid = locator<AuthService>().currentUser().uid;
    var returnData;
    _userId = uid;
    await locator<ApiService>().getVerificationStatus(uid: uid).then((data) {
      _verificationStatus = data.body['userAccess'];
      returnData = data.body;
    });
    return returnData;
  }

  Future<dynamic> populateVehicles() async {
    await locator<ApiService>().getVehicles(uid: _userId).then((data) {

      List<dynamic> vehiclesFromApi = new List.from(data.body);
      if (vehiclesFromApi.isEmpty) {

        noVehicles = true;
      } else {
        vehiclesFromApi.forEach((data) {
          vehicles.add(Vehicle.fromDoc(data));
        });
        setState(() {
          noVehicles = false;
        });
      }
    });
  }

  Widget vehiclesPresent() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        child:
            Text("----------------------------", textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 0),
        child: Text("Selected Vehicle: $selectedVehicle ",
            textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        child: Text("Select Vehicle :", textAlign: TextAlign.center),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 0, left: 4, right: 4, bottom: 0),
          child: setupAlertDialogueContainer()),
    ]);
  }

  setupAlertDialogueContainer() {
    return Container(
      height: 40.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: vehicles.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => Card(
            child: InkWell(
          onTap: () {
            setState(() {
              selectedVehicle = vehicles[index].plateNumber;
            });
          },
          child: Center(
            child: Text(vehicles[index].plateNumber),
          ),
        )),
      ),
    );
  }
}
