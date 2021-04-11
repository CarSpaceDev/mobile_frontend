import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class VehicleSelectorWidget extends StatefulWidget {
  @override
  _VehicleSelectorWidgetState createState() => _VehicleSelectorWidgetState();
}

class _VehicleSelectorWidgetState extends State<VehicleSelectorWidget> with TickerProviderStateMixin {
  List<Widget> vehicles2 = [
    Container(
      color: Colors.pink,
      child: Center(child: Text("1")),
    ),
    Container(
      color: Colors.redAccent,
      child: Center(child: Text("2")),
    ),
    Container(
      color: Colors.purple,
      child: Center(child: Text("3")),
    ),
    Container(
      color: Colors.black12,
      child: Center(child: Text("4")),
    ),
    Container(
      color: Colors.yellowAccent,
      child: Center(child: Text("5")),
    ),
  ];

  int index = 0;
  int actualIndex = 0;
  PageController controller;

  List<Vehicle> vehicles = [];
  bool noVehicles;

  @override
  void initState() {
    controller = PageController(initialPage: index);
    populateVehicles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      child: Column(
        children: [
          CSText(
            "VEHICLE SELECTED",
            textAlign: TextAlign.center,
            textType: TextType.H5Bold,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: actualIndex == 0
                    ? Container()
                    : InkWell(
                        onTap: () {
                          controller.previousPage(duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                        },
                        child: AspectRatio(aspectRatio: 1, child: vehicles2[calculatePage(index % vehicles2.length, previous: true)]),
                      ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                child: PageView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    controller: controller,
                    onPageChanged: (i) {
                      setState(() {
                        index = i % vehicles2.length;
                        actualIndex = i;
                      });
                      print(index);
                      print(actualIndex);
                    },
                    itemBuilder: (context, index) {
                      return vehicles2[index % vehicles2.length];
                    }),
              ),
              Flexible(
                child: actualIndex == vehicles2.length - 1
                    ? Container()
                    : InkWell(
                        onTap: () {
                          controller.nextPage(duration: Duration(milliseconds: 100), curve: Curves.easeIn);
                        },
                        child: AspectRatio(aspectRatio: 1, child: vehicles2[calculatePage(index % vehicles2.length, previous: false)]),
                      ),
              ),
            ],
          ),
          Container(
            height: 150,
            width: 300,
            child: PageView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: SizedBox(
                      child: Card(
                        color: vehicles[index].isVerified ? Colors.white : Colors.grey[200],
                        elevation: 4.0,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(vehicles[index].plateNumber + " (${vehicles[index].isVerified ? 'verified' : 'unverified'})",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // _showActionsDialog(index: index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Icon(
                                            Icons.more_vert,
                                            color: Colors.blueAccent,
                                          )),
                                    ),
                                  )
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
                                        imageUrl: vehicles[index].vehicleImage,
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
                                            TextSpan(text: 'Make : ', style: TextStyle(color: Colors.grey)),
                                            TextSpan(text: vehicles[index].make)
                                          ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: RichText(
                                          text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                            TextSpan(text: 'Model : ', style: TextStyle(color: Colors.grey)),
                                            TextSpan(text: vehicles[index].model)
                                          ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: RichText(
                                          text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                                            TextSpan(text: 'Color : ', style: TextStyle(color: Colors.grey)),
                                            TextSpan(text: vehicles[index].color)
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
                  );
                }),
          )
        ],
      ),
    );
  }

  void populateVehicles() {
    locator<ApiService>().getVehicles(uid: locator<AuthService>().currentUser().uid).then((data) {
      List<dynamic> vehiclesFromApi = new List.from(data.body);
      if (vehiclesFromApi.isEmpty) {
        noVehicles = true;
      } else {
        vehiclesFromApi.forEach((vehicle) {
          vehicles.add(Vehicle.fromJson(vehicle));
        });
        noVehicles = false;
      }
      setState(() {});
    });
  }

  calculatePage(int v, {bool previous = true}) {
    if (previous) {
      if (v == 0) return vehicles2.length - 1;
      return v - 1;
    } else {
      if (v == vehicles2.length - 1) return 0;
      return v + 1;
    }
  }
}
