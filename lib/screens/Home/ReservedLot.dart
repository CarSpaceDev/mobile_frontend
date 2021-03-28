import 'package:carspace/model/DriverReservation.dart';
import 'package:flutter/material.dart';

class ReservedLot extends StatefulWidget {
  final DriverReservation reservation;
  const ReservedLot(this.reservation);
  @override
  _ReservedLotState createState() => _ReservedLotState();
}

class _ReservedLotState extends State<ReservedLot> {
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
                      widget.reservation.lotAddress.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        widget.reservation.lotImage,
                        fit: BoxFit.fill,
                        height: 150,
                        width: 250,
                      )),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Vehicle Selected : \n${widget.reservation.vehicleId}", textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Date Booked :\n${widget.reservation.dateCreated}", textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Time Booked : \n${widget.reservation.timeCreated}", textAlign: TextAlign.center),
                  ),
                ],
              )),
            ],
          ),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Reservation',
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
