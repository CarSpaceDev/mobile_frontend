import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/blocs/vehicle/vehicle_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/screens/DriverScreens/Vehicles/VehicleRegistrationScreen.dart';
import 'package:carspace/screens/Home/PopupNotifications.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:chopper/chopper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation.dart';
import 'VehicleEditScreen.dart';
import 'VehicleQRCodeGeneration.dart';

class VehicleManagementScreen extends StatefulWidget {
  @override
  _VehicleManagementScreenState createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('My Vehicles'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.bloc<VehicleRepoBloc>().add(InitializeVehicleRepo(uid: locator<AuthService>().currentUser().uid));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            PopupNotifications.showNotificationDialog(context,
                barrierDismissible: true,
                child: CSTile(
                  borderRadius: 25,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: scanQR,
                        icon: Icon(
                          Icons.qr_code,
                          color: Colors.blueAccent,
                        ),
                        label: Text('Add from code', style: TextStyle(color: Colors.blueAccent)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          locator<NavigationService>().pushNavigateToWidget(
                            getPageRoute(
                              VehicleRegistrationScreen(
                                fromHomeScreen: true,
                              ),
                              RouteSettings(name: "ADD-VEHICLE"),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Colors.blueAccent,
                        ),
                        label: Text('Add new vehicle', style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                ));
          },
          child: Icon(Icons.add)),
      body: BlocBuilder<VehicleRepoBloc, VehicleRepoState>(builder: (context, state) {
        if (state is VehicleRepoReady) {
          if (state.vehicles.isEmpty)
            return Center(child: Text("It's lonely here, lets's add a vehicle!"));
          else
            return ListView.builder(
              itemCount: state.vehicles.length,
              itemBuilder: (BuildContext context, index) {
                return VehicleListTile(
                    vehicle: state.vehicles[index],
                    onTap: () {
                      PopupNotifications.showNotificationDialog(context,
                          barrierDismissible: true, child: VehicleOverview(vehicle: state.vehicles[index]));
                    });
              },
            );
        }
        return VehicleManagementLoading();
      }),
    );
  }
}

class VehicleOverview extends StatelessWidget {
  final Vehicle vehicle;
  VehicleOverview({@required this.vehicle});
  @override
  Widget build(BuildContext context) {
    return CSTile(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16),
      borderRadius: 25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VehicleDetail(vehicle: vehicle),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (vehicle.ownerId == locator<AuthService>().currentUser().uid)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PopUp.showOption(
                          context: context,
                          title: "Edit ${vehicle.plateNumber}?",
                          body: "After saving, the vehicle will need to be reverified. Proceed?",
                          onAccept: () {
                            locator<NavigationService>().pushNavigateToWidget(
                              getPageRoute(
                                VehicleEditScreen(
                                  vehicle: vehicle,
                                ),
                                RouteSettings(name: "EDIT-VEHICLE"),
                              ),
                            );
                          });
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                    ),
                    label: Text('Edit', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
              if (vehicle.ownerId == locator<AuthService>().currentUser().uid)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PopUp.showOption(
                          context: context,
                          title: "Delete vehicle ${vehicle.plateNumber}?",
                          body:
                              "You will no longer be able to use this vehicle until you add it again, and it is verified",
                          onAccept: () {
                            locator<NavigationService>()
                                .navigatorKey
                                .currentContext
                                .bloc<VehicleBloc>()
                                .add(DeleteVehicle(vehicle: vehicle));
                          });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    label: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              if (vehicle.ownerId != locator<AuthService>().currentUser().uid)
                Flexible(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PopUp.showOption(
                          context: context,
                          title: "Remove vehicle ${vehicle.plateNumber}?",
                          body: "You will no longer be able to use this vehicle until you add it again.",
                          onAccept: () {
                            locator<NavigationService>()
                                .navigatorKey
                                .currentContext
                                .bloc<VehicleBloc>()
                                .add(RemoveVehicle(vehicle: vehicle));
                          });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    label: Text('Remove', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
            ],
          ),
          if (vehicle.ownerId == locator<AuthService>().currentUser().uid)
            TextButton.icon(
              onPressed: () {
                if (vehicle.status == VehicleStatus.Unverified || vehicle.status == VehicleStatus.Blocked) {
                  PopUp.showError(
                      context: context,
                      title: "Vehicle has invalid status",
                      body: "Only verified and unblocked vehicles can be used");
                } else {
                  generateQR(vehicle: vehicle);
                }
              },
              icon: Icon(
                Icons.qr_code,
                color: Colors.green,
              ),
              label: Text('Generate Share Code', style: TextStyle(color: Colors.green)),
            ),
          if (vehicle.ownerId == locator<AuthService>().currentUser().uid && vehicle.currentUsers.length != 1)
            OtherVehicleUsers(vehicle: vehicle)
        ],
      ),
    );
  }
}

class OtherVehicleUsers extends StatelessWidget {
  final Vehicle vehicle;
  OtherVehicleUsers({@required this.vehicle});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      color: TileColor.None,
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.zero,
      title: CSText(
        "SHARED WITH",
        textColor: TextColor.Black,
        textType: TextType.Button,
        textAlign: TextAlign.center,
        padding: EdgeInsets.only(top: 4),
      ),
      body: Container(
        height: 48,
        child: ListView.builder(
            itemCount: vehicle.currentUsers.length,
            // ignore: missing_return
            itemBuilder: (context, index) {
              if (vehicle.currentUsers[index] != vehicle.ownerId) {
                return CSSegmentedTile(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.zero,
                  title: UserName(uid: vehicle.currentUsers[index]),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PopUp.showOption(
                          context: context,
                          title: "Revoke access for vehicle ${vehicle.plateNumber}?",
                          body:
                              "The selected user will no longer be able to use this vehicle until you authorize again.",
                          onAccept: () {
                            locator<NavigationService>()
                                .navigatorKey
                                .currentContext
                                .bloc<VehicleBloc>()
                                .add(RevokeVehiclePermission(vehicle: vehicle, uid: vehicle.currentUsers[index]));
                          });
                    },
                    icon: Icon(
                      CupertinoIcons.xmark,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }
              return Container();
            }),
      ),
    );
  }
}

class UserName extends StatelessWidget {
  final String uid;
  UserName({@required this.uid});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: locator<ApiService>().getUserData(uid: uid),
        builder: (context, result) {
          if (result.hasData) {
            return CSText(
              "${result.data.body["displayName"]}".toUpperCase(),
              textType: TextType.Button,
              textColor: TextColor.Primary,
            );
          }
          return CSText(". . .");
        });
  }
}

class VehicleDetail extends StatelessWidget {
  final Vehicle vehicle;
  VehicleDetail({@required this.vehicle});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CSTile(
          color: TileColor.None,
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .45),
                child: CSText(
                  "${vehicle.make} ${vehicle.model}",
                  textType: TextType.Button,
                  overflow: TextOverflow.ellipsis,
                  textColor: TextColor.Primary,
                ),
              ),
              CSText(
                vehicle.plateNumber,
                textColor: TextColor.Primary,
                textType: TextType.Button,
              ),
            ],
          ),
        ),
        buildVehicleImage(context),
        CSTile(
          color: TileColor.None,
          margin: EdgeInsets.symmetric(vertical: 16),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CSText(
                vehicle.ownerId == locator<AuthService>().currentUser().uid ? "Owned" : "Shared with me",
                textColor: TextColor.Primary,
                padding: EdgeInsets.only(top: 4),
              ),
              CSText(
                "Registry expires: ${formatDate(vehicle.expireDate, [MM, " ", dd, ", ", yyyy])}",
                textColor: TextColor.Primary,
                padding: EdgeInsets.only(top: 4),
              ),
              CSText(
                "Type: ${vehicle.type}".replaceAll("VehicleType.", ""),
                textColor: TextColor.Primary,
                padding: EdgeInsets.only(top: 4),
              ),
              CSText(
                "Status: ${vehicle.status}".replaceAll("VehicleStatus.", ""),
                textColor: TextColor.Primary,
                padding: EdgeInsets.only(top: 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InkWell buildVehicleImage(BuildContext context) {
    return InkWell(
      onTap: () {
        PopupNotifications.showNotificationDialog(context,
            barrierDismissible: true,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black12,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: vehicle.vehicleImage,
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          LinearProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ));
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: Colors.black12,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: vehicle.vehicleImage,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    LinearProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VehicleListTile extends StatelessWidget {
  final Vehicle vehicle;
  final Function onTap;
  VehicleListTile({@required this.vehicle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return CSTile(
      onTap: onTap,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(8),
      borderRadius: 16,
      color: vehicle.status == VehicleStatus.Blocked
          ? TileColor.Red
          : vehicle.status == VehicleStatus.Available
              ? TileColor.White
              : TileColor.DarkGrey,
      shadow: true,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.black12,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: vehicle.vehicleImage,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              LinearProgressIndicator(value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: CSTile(
                  color: TileColor.None,
                  margin: EdgeInsets.only(left: 16),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .45),
                        child: CSText(
                          "${vehicle.make} ${vehicle.model}",
                          textType: TextType.Button,
                          overflow: TextOverflow.ellipsis,
                          textColor: TextColor.Primary,
                        ),
                      ),
                      CSText(
                        vehicle.plateNumber,
                        textColor: TextColor.Primary,
                        padding: EdgeInsets.only(top: 4),
                      ),
                      CSText(
                        "${vehicle.status}".replaceAll("VehicleStatus.", ""),
                        textColor: TextColor.Primary,
                        padding: EdgeInsets.only(top: 4),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

void scanQR() {
  Navigator.of(locator<NavigationService>().navigatorKey.currentContext).pop();
  FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.QR).then((value) {
    RegExp regExp = new RegExp("\\w{28}_[0-9]{13}_[0-9]{6}");
    //if the scan is cancelled
    if (value == "-1") {
      return;
    }
    //else check for regexp match
    if (regExp.hasMatch(value)) {
      //check for code validity/expiration
      if (DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(int.parse(value.substring(29, 42))))) {
        var payload = {"code": value, "uid": locator<AuthService>().currentUser().uid};
        showDialog(
            barrierDismissible: false,
            context: locator<NavigationService>().navigatorKey.currentContext,
            builder: (_) {
              return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: VehicleAddDetails(code: value));
            });
      } else {
        showError(locator<NavigationService>().navigatorKey.currentContext,
            error: "Code expired, please request a valid code");
      }
    } else {
      showError(locator<NavigationService>().navigatorKey.currentContext, error: "Code Invalid");
    }
  });
}

void generateQR({@required Vehicle vehicle}) {
  locator<NavigationService>().goBack();
  showDialog(
      barrierDismissible: false,
      context: locator<NavigationService>().navigatorKey.currentContext,
      builder: (_) {
        return Dialog(
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: csStyle.primary,
                ),
                Text(
                  "Generating QR Code",
                  style: TextStyle(color: csStyle.primary),
                )
              ],
            ),
          ),
        );
      });
  locator<ApiService>().generateShareCode(vehicle.plateNumber, vehicle.ownerId).then((Response data) {
    if (data.statusCode == 200) {
      locator<NavigationService>().goBack();
      showDialog(
          context: locator<NavigationService>().navigatorKey.currentContext,
          builder: (_) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Share Code for ${vehicle.plateNumber}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  VehicleTransferCodeScreen(
                      payload: VehicleTransferQrPayLoad(code: data.body["code"], expiry: data.body["expiry"])),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: FlatButton(
                        color: Colors.grey,
                        onPressed: () {
                          locator<NavigationService>().goBack();
                        },
                        child: Text("Close")),
                  )
                ],
              ),
            );
          });
    } else {
      locator<NavigationService>().goBack();
      showError(locator<NavigationService>().navigatorKey.currentContext, error: "Server error, please try again later");
    }
  }).catchError((error) {
    locator<NavigationService>().goBack();
    showError(locator<NavigationService>().navigatorKey.currentContext, error: "Server error, please try again later");
  });
}

void showError(BuildContext context, {@required String error}) {
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
              backgroundColor: Theme.of(context).primaryColor,
            ),
            Text(
              "Loading",
              style: TextStyle(color: Theme.of(context).primaryColor),
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
        FirebaseFirestore.instance.collection("vehicles").doc(value.body["plateNumber"]).get().then((doc){
          setState(() {
            vehicleDetails = Vehicle.fromDoc(doc);
          });
        });
      } else {
        Navigator.of(context).pop();
        showError(error: json.decode(value.error)["error"]);
      }
    }).catchError((error) {
      Navigator.of(context).pop();
      showError(error: "Error retrieving data. Please try again.");
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
                              height: 50,
                              width: 50,
                              child: AspectRatio(
                                  aspectRatio: 1, child: CircularProgressIndicator(value: downloadProgress.progress)))),
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
        Navigator.of(context).pop();
        showError(error: "An error occurred in adding the vehicle, please try again.");
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
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          "Loading",
          style: TextStyle(color: Theme.of(context).primaryColor),
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
