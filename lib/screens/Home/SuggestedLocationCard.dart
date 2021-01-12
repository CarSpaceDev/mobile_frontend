import "package:flutter/material.dart";

class SuggestedLocationCard extends StatelessWidget {
  final String name;
  final String address;
  final double price;
  final double distance;
  final Function callback;
  SuggestedLocationCard({Key key, this.name, this.address, this.price, this.distance, this.callback}) : super(key: key);

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
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                address,
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
                        '${distance.toStringAsFixed(2)} km',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  InkWell(onTap: callback, child: Text("Select Lot", style: TextStyle(fontSize: 16))),
                  Text("${price.toStringAsFixed(2)}/hour", style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
