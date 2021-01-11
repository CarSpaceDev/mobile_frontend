import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

import '../../navigation.dart';
import 'VehicleQRCodeGeneration.dart';

class VehicleManagementScreen extends StatefulWidget {
  @override
  _VehicleManagementScreenState createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  List<Vehicle> vehicles = [];
  bool noVehicles;
  @override
  void initState() {
    noVehicles = false;
    populateVehicles();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicles'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            locator<NavigationService>().goBack();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                vehicles = [];
                noVehicles = false;
              });
              populateVehicles();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showAddVehicleChoices(context);
          },
          child: Icon(Icons.add)),
      body: vehicles.length == 0
          ? noVehicles
              ? Center(child: Text("It's lonely here, lets's add a vehicle!"))
              : VehicleManagementLoading()
          : vehicleEntries(),
    );
  }

  ListView vehicleEntries() {
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (BuildContext context, index) {
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
                            _showActionsDialog(index: index);
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
      },
    );
  }

  _showActionsDialog({int index}) {
    return showDialog(
        context: context,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                ),
                                Text('Edit', style: TextStyle(color: Colors.blueAccent))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: [
                                Icon(Icons.delete, color: Colors.redAccent),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              if (vehicles[index].isVerified) {
                                generateQR(index);
                              } else {
                                Navigator.of(context).pop();
                                showError(error: "This vehicle is not yet verified");
                              }
                            },
                            child: Column(
                              children: [Icon(Icons.qr_code, color: Colors.green), Text('Generate Share Code', style: TextStyle(color: Colors.green))],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: [Icon(Icons.more_horiz), Text('See more')],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  void generateQR(int index) {
    print(vehicles[index].toJson());
    print({"vehicleId": vehicles[index].plateNumber, "ownerId": vehicles[index].ownerId});
    if (locator<AuthService>().currentUser().uid != vehicles[index].ownerId) {
      Navigator.of(context).pop();
      showError(error: "You do not own this vehicle, please contact the original owner");
    } else {
      Navigator.of(context).pop();
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              child: Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: themeData.primaryColor,
                    ),
                    Text(
                      "Generating QR Code",
                      style: TextStyle(color: themeData.primaryColor),
                    )
                  ],
                ),
              ),
            );
          });
      locator<ApiService>().generateShareCode(vehicles[index].plateNumber, vehicles[index].ownerId).then((Response data) {
        if (data.statusCode == 200) {
          print(data.body);
          Navigator.of(context).pop();
          showDialog(
              context: context,
              builder: (_) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Share Code for ${vehicles[index].plateNumber}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      VehicleTransferCodeScreen(payload: VehicleTransferQrPayLoad(code: data.body["code"], expiry: data.body["expiry"])),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FlatButton(
                            color: Colors.grey,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Close")),
                      )
                    ],
                  ),
                );
              });
        } else {
          Navigator.of(context).pop();
          showError(error: "Server error, please try again later");
        }
      });
    }
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
                        Icons.announcement,
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
          );
        });
  }

  void showAddVehicleChoices(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: GestureDetector(
                          onTap: scanQR,
                          child: Column(
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: Colors.blueAccent,
                              ),
                              Text('Add from code', style: TextStyle(color: Colors.blueAccent))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            locator<NavigationService>().pushNavigateTo(LoginRoute);
                            context.read<LoginBloc>().add(NavigateToVehicleAddEvent());
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.blueAccent,
                              ),
                              Text('Add new vehicle', style: TextStyle(color: Colors.blueAccent))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void scanQR() {
    Navigator.of(context).pop();
    FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR).then((value) {
      RegExp regExp = new RegExp("\\w{28}_[0-9]{13}_[0-9]{6}");
      print(value);
      //if the scan is cancelled
      if (value == "-1") {
        return;
      }
      //else check for regexp match
      print(regExp.hasMatch(value));
      if (regExp.hasMatch(value)) {
        print(DateTime.now());
        print(value.substring(29, 42));
        print(DateTime.fromMillisecondsSinceEpoch(int.parse(value.substring(29, 42))));
        //check for code validity/expiration
        if (DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(int.parse(value.substring(29, 42))))) {
          var payload = {"code": value, "uid": locator<AuthService>().currentUser().uid};
          print(payload);
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) {
                return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), child: VehicleAddDetails(code: value));
              });
        } else {
          showError(error: "Code expired, please request a valid code");
        }
      } else {
        showError(error: "Code Invalid");
      }
    });
  }
}

class VehicleManagementLoading extends StatelessWidget {
  const VehicleManagementLoading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: themeData.primaryColor,
            ),
            Text(
              "Loading",
              style: TextStyle(color: themeData.primaryColor),
            )
          ],
        ),
      )),
    );
  }
}

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
        print(value.body);
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
          //show success dialog
          print("Success");
          Navigator.of(context).pop();
          showSuccess();
        } else {
          print("Fail");
          Navigator.of(context).pop();
          showError(error: json.decode(value.error)["error"]);
        }
      }).catchError((err) {
        //show an error dialog
        print(err);
        print("Error in add vehicle from code");
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
            backgroundColor: themeData.primaryColor,
          ),
        ),
        Text(
          "Loading",
          style: TextStyle(color: themeData.primaryColor),
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
