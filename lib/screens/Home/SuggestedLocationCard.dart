import 'package:carspace/model/Lot.dart';
import "package:flutter/material.dart";

class SuggestedLocationCard extends StatelessWidget {
  final Lot lot;
  final Function callback;
  SuggestedLocationCard({Key key, this.lot, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .15,
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                lot.address.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "Available hours " + lot.availableFrom.toString() + " - " + lot.availableTo.toString(),
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.location_on, size: 16),
                      Text(
                        '${lot.distance.toStringAsFixed(2)} km',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  InkWell(onTap: callback, child: Text("Select Lot", style: TextStyle(fontSize: 16))),
                  Text("${lot.pricing.toStringAsFixed(2)}/hour", style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
