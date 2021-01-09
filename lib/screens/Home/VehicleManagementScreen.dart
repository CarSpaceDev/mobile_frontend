import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:chopper/chopper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../navigation.dart';
import 'VehicleQRCodeGeneration.dart';

class VehicleManagementScreen extends StatefulWidget {
  @override
  _VehicleManagementScreenState createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  _showDialog({int index}) {
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
                              generateQR(index);
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
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Error", textAlign: TextAlign.center),
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
                        "You do not own this vehicle, please contact the original owner",
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      Navigator.of(context).pop();
      showDialog(
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
                return AlertDialog(
                  title: Text(
                    "Share Code for ${vehicles[index].plateNumber}",
                    textAlign: TextAlign.center,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  content: VehicleTransferCodeScreen(payload: VehicleTransferQrPayLoad(code: data.body["code"], expiry: data.body["expiry"])),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Close"))
                  ],
                );
              });
        } else {
          print("API ERROR");
        }
      });
    }
  }

  List<Vehicle> vehicles = [];

  @override
  void initState() {
    User currentUser = locator<AuthService>().currentUser();
    locator<ApiService>().getVehicles(uid: currentUser.uid).then((data) {
      new List.from(data.body).forEach((vehicle) {
        vehicles.add(Vehicle.fromJson(vehicle));
      });
      setState(() {});
    });
    super.initState();
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
              User currentUser = locator<AuthService>().currentUser();
              setState(() {
                vehicles = [];
              });

              locator<ApiService>().getVehicles(uid: currentUser.uid).then((data) {
                new List.from(data.body).forEach((vehicle) {
                  vehicles.add(Vehicle.fromJson(vehicle));
                });
                setState(() {});
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
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
                                  onTap: () {},
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
          },
          child: Icon(Icons.add)),
      body: vehicles.length == 0
          ? Container(
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
            )
          : ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (BuildContext context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: SizedBox(
                    child: Card(
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
                                  child: Text(vehicles[index].plateNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showDialog(index: index);
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
                                  child: Image.network(
                                    vehicles[index].vehicleImage,
                                    scale: 2.5,
                                    height: 80,
                                    width: 80,
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
            ),
    );
  }
}
