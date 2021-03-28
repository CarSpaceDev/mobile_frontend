import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class VehicleAddDetails extends StatefulWidget {
  final String code;
  VehicleAddDetails({@required this.code});
  @override
  _VehicleAddDetailsState createState() => _VehicleAddDetailsState(this.code);
}

class _VehicleAddDetailsState extends State<VehicleAddDetails> {
  final String code;
  Vehicle vehicleDetails;
  _VehicleAddDetailsState(this.code);
  @override
  void initState() {
    locator<ApiService>().getVehicleAddDetails(code).then((Response value) {
      if (value.statusCode == 200) {
        setState(() {
          vehicleDetails = Vehicle.fromJson(value.body);
        });
      } else {
        Navigator.of(context).pop();
        showError(error: json.decode(value.error)["error"]);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: vehicleDetails == null
          ? loading()
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Vehicle Info",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: vehicleDetails.vehicleImage,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: Container(
                              height: 50, width: 50, child: AspectRatio(aspectRatio: 1, child: CircularProgressIndicator(value: downloadProgress.progress)))),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${vehicleDetails.make} ${vehicleDetails.model}", textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Plate Number: ${vehicleDetails.plateNumber}", textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Color: ${vehicleDetails.color}", textAlign: TextAlign.center),
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: Navigator.of(context).pop,
                            child: Container(
                              child: Center(
                                  child: Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 32,
                              )),
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              confirmDialog(context);
                            },
                            child: Container(
                              child: Center(
                                  child: Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 32,
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future confirmDialog(BuildContext context) async {
    var choice = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text("Are you sure you want to add this vehicle?"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("No")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Yes"))
            ],
          );
        });
    if (choice) {
      locator<ApiService>().addVehicleFromCode(locator<AuthService>().currentUser().uid, code).then((value) {
        if (value.statusCode == 200) {
          Navigator.of(context).pop();
          showSuccess();
        } else {
          Navigator.of(context).pop();
          showError(error: json.decode(value.error)["error"]);
        }
      }).catchError((err) {
        showError(error: "We're currently having problems processing your request. Please try again");
      });
    }
  }

  Widget loading() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: csTheme.primaryColor,
          ),
        ),
        Text(
          "Loading",
          style: TextStyle(color: csTheme.primaryColor),
        )
      ],
    );
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
                        Icons.error,
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
            actions: [FlatButton(onPressed: Navigator.of(context).pop, child: Text("Close"))],
          );
        });
  }

  void showSuccess() {
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
                      "Your request to add the vehicle ${vehicleDetails.make} ${vehicleDetails.model} ${vehicleDetails.plateNumber} has been sent to the owner. You will be notified when the vehicle has been added to your account.",
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
