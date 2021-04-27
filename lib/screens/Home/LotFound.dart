import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/DriverReservation.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/screens/Navigation/DriverNavigationService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
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
                    padding: const EdgeInsets.only(
                        top: 25, bottom: 8, right: 8, left: 8),
                    child: Text(
                      widget.lot.address.toString(),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: widget.type == 0
                        ? Text("Price :\n${widget.lot.pricing}Php / Hour",
                            textAlign: TextAlign.center)
                        : Text("Price :\n${widget.lot.pricePerDay}Php / Hour",
                            textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                        "Available from: \n${widget.lot.availableFrom}H to ${widget.lot.availableTo}H",
                        textAlign: TextAlign.center),
                  ),
                  if (widget.type == 1)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CheckboxListTile(
                          value: recurring,
                          onChanged: _recurringChangeValue,
                          title: new Text('Reserve as recurring reservation'),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.blue),
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
                            color: Theme.of(context).secondaryHeaderColor,
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
                                            SizeConfig.textMultiplier * 2.5),
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
                              if (widget.type == 0)
                                book();
                              else
                                reserve();
                            },
                            color: Theme.of(context).secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              width: SizeConfig.widthMultiplier * 50,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: widget.type == 0
                                      ? Text(
                                          'Book',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2.5),
                                        )
                                      : Text(
                                          'Reserve',
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
            padding:
                const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 20),
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
              backgroundColor: Theme.of(context).primaryColor,
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
    await locator<ApiService>().bookLot(body).then((value) {
      print(value.body);
      print(value.statusCode);
      Navigator.of(context).pop();
      if (value.body["code"] == 200) {
        locator<NavigationService>().pushReplaceNavigateTo(DashboardRoute);
        successfulBooking(
            DriverReservation.fromJson(value.body["reservationData"]));
      } else {
        showMessage(value.body["message"]);
      }
    }).catchError((err) {
      print(err);
    });
  }

  reserve() async {
    var reserve_type;
    if (recurring == false) {
      reserve_type = 0;
    } else {
      reserve_type = 1;
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
    await locator<ApiService>().reserveLot(reserve_type, body).then((value) {
      print(value.body);
      print(value.statusCode);
      setState(() {
        working = false;
      });
      // Navigator.of(context).pop();
      if (value.body["code"] == 200) {
        locator<NavigationService>().pushReplaceNavigateTo(DashboardRoute);
        successfulBooking(
            DriverReservation.fromJson(value.body["reservationData"]));
      } else {
        showMessage(value.body["message"]);
      }
    }).catchError((err) {
      print(err);
    });
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
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(locator<NavigationService>()
                                .navigatorKey
                                .currentContext)
                            .pop(null);
                        locator<ApiService>().notifyOnTheWay({
                          "userId": widget.user,
                          "lotAddress": widget.lot.address.toString(),
                          "partnerId": widget.lot.partnerId
                        });
                        DriverNavigationService(reservationId: v.reservationId)
                            .navigateViaMapBox(v.coordinates);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined),
                          Text("Navigate To Lot")
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
