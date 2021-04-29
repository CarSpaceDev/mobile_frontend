import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/repo/currentReservationRepo/current_reservation_bloc.dart';
import 'package:carspace/repo/userRepo/user_repo_bloc.dart';
import 'package:carspace/repo/vehicleRepo/vehicle_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/ImageUploadWidget.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:carspace/reusable/NavigationDrawer.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/Reservations/DriverReservationScreen.dart';
import 'package:carspace/screens/Vehicles/VehicleSelectorWidget.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'ParkNowWidget.dart';

class HomeDashboard extends StatefulWidget {
  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    locator<NavigationService>()
        .navigatorKey
        .currentContext
        .read<GeolocationBloc>()
        .add(InitializeGeolocator());
    super.initState();
  }

  @override
  void dispose() {
    locator<NavigationService>()
        .navigatorKey
        .currentContext
        .read<GeolocationBloc>()
        .add(CloseGeolocationStream());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: CSText("Dashboard",
            textType: TextType.H4, textColor: TextColor.White),
        actions: [
          WalletInfoWidget(),
        ],
        leading: CSMenuButton(),
      ),
      drawer: HomeNavigationDrawer(),
      body: SafeArea(
        child: BackgroundImage(
          padding: EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocBuilder<UserRepoBloc, UserRepoState>(
                      builder: (BuildContext context, UserRepoState userState) {
                    if (userState is UserRepoReady &&
                        userState.user.isBlocked) {
                      return Container();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry != null) {
                      if (userState is UserRepoReady &&
                          userState.user.licenseExpiry
                              .isBefore(DateTime.now())) {
                        return Container();
                      }
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry == null) {
                      return Container();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.userAccess > 110 && userState.user.currentReservation!=null) {
                      context.bloc<CurrentReservationBloc>().add(
                          InitCurrentReservationRepo(
                              uid: userState.user.currentReservation));
                      return BlocBuilder<CurrentReservationBloc,
                              CurrentReservationState>(
                          builder: (BuildContext context,
                              CurrentReservationState state) {
                        if (state is UpdatedCurrentReservation) {
                          return ReservationTileWidget(
                              reservation: state.reservation);
                        }
                        return Container();
                      });
                    } else
                      return Container();
                  }),
                  BlocBuilder<UserRepoBloc, UserRepoState>(
                      builder: (BuildContext context, UserRepoState userState) {
                    if (userState is UserRepoReady &&
                        userState.user.isBlocked) {
                      return Container();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry != null) {
                      if (userState is UserRepoReady &&
                          userState.user.licenseExpiry
                              .isBefore(DateTime.now())) {
                        return Container();
                      }
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry == null) {
                      return Container();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.currentReservation != null)
                      return Container();
                    return VehicleSelectorWidget();
                  }),
                  BlocBuilder<UserRepoBloc, UserRepoState>(
                      builder: (BuildContext context, UserRepoState userState) {
                    if (userState is UserRepoReady &&
                        userState.user.isBlocked) {
                      return BlockedUserWidget(uid: userState.user.uid);
                    }
                    if (userState is UserRepoReady &&
                        userState.user.creditTransactionId != null) {
                      return UserHasCreditWidget(
                          uid: userState.user.uid,
                          transactionId: userState.user.creditTransactionId);
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry != null) {
                      if (userState is UserRepoReady &&
                          userState.user.licenseExpiry
                              .isBefore(DateTime.now())) {
                        return UpdateLicenseWidget();
                      }
                    }
                    if (userState is UserRepoReady &&
                        userState.user.licenseExpiry == null) {
                      return NoLicenseWidget();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.userAccess < 200) {
                      return WaitForVerification();
                    }
                    if (userState is UserRepoReady &&
                        userState.user.currentVehicle != null &&
                        userState.user.currentReservation == null)
                      return BlocBuilder<VehicleRepoBloc, VehicleRepoState>(
                          builder: (BuildContext context,
                              VehicleRepoState vehicleState) {
                        if (vehicleState is VehicleRepoReady) {
                          return BlocBuilder<GeolocationBloc, GeolocationState>(
                              builder: (BuildContext context,
                                  GeolocationState state) {
                            Vehicle vehicle;
                            try {
                              vehicle = vehicleState.vehicles.firstWhere((v) =>
                                  v.plateNumber ==
                                  userState.user.currentVehicle);
                            } catch (e) {}
                            if (state is GeolocatorReady &&
                                vehicle != null &&
                                vehicle?.status == VehicleStatus.Available) {
                              return ParkNowWidget(
                                enabled: true,
                                selectedVehicle: vehicle,
                              );
                            } else
                              return ParkNowWidget(
                                enabled: false,
                              );
                          });
                        }
                        return ParkNowWidget(
                          enabled: false,
                        );
                      });
                    else
                      return ParkNowWidget(
                        enabled: false,
                      );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlockedUserWidget extends StatefulWidget {
  final String uid;
  BlockedUserWidget({@required this.uid});

  @override
  _BlockedUserWidgetState createState() => _BlockedUserWidgetState();
}

class _BlockedUserWidgetState extends State<BlockedUserWidget> {
  DateTime releaseDate;
  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("blockedDrivers")
        .doc(widget.uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        DateTime temp = doc.data()["dateCreated"] != null
            ? doc.data()["dateCreated"].toDate()
            : null;
        if (temp != null) {
          temp.add(Duration(days: 3));
          setState(() {
            releaseDate = temp;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CSTile(
      borderRadius: 8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            CupertinoIcons.info,
            color: Colors.blueAccent,
            size: 45,
          ),
          CSText(
            "Your driver account is currently blocked",
            textType: TextType.H4,
            padding: EdgeInsets.symmetric(vertical: 16),
            textAlign: TextAlign.center,
          ),
          CSText(
            "You can use the app again on ${releaseDate != null ? "${formatDate(releaseDate, [
                MM,
                " ",
                dd,
                ", ",
                yyyy,
              ])}" : ". . ."} ",
            padding: EdgeInsets.only(top: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class UserHasCreditWidget extends StatefulWidget {
  final String uid;
  final String transactionId;
  UserHasCreditWidget({@required this.uid, @required this.transactionId});

  @override
  _UserHasCreditWidgetState createState() => _UserHasCreditWidgetState();
}

class _UserHasCreditWidgetState extends State<UserHasCreditWidget> {
  double creditBalance;
  double userBalance;
  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("transactions")
        .doc(widget.transactionId)
        .get()
        .then((doc) {
      if (doc.exists) {
        double temp = doc.data()["balance"] != null
            ? doc.data()["balance"].toDouble()
            : null;
        if (temp != null) {
          setState(() {
            creditBalance = temp;
          });
        }
      }
      locator<ApiService>()
          .getWalletStatus(uid: locator<AuthService>().currentUser().uid)
          .then((value) {
        if (value.statusCode == 200)
          setState(() {
            userBalance = double.parse("${value.body["balance"]}");
          });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CSTile(
      borderRadius: 8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            CupertinoIcons.info,
            color: Colors.blueAccent,
            size: 45,
          ),
          CSText(
            "You  currently have a pending balance of $creditBalance",
            textType: TextType.H4,
            padding: EdgeInsets.symmetric(vertical: 16),
            textAlign: TextAlign.center,
          ),
          CSTile(
            onTap: () async {
              try {
                locator<ApiService>().payCredit({
                  "userId": locator<AuthService>().currentUser().uid,
                  "transactionId": this.widget.transactionId
                }).then((value) => print(value.body));
              } catch (e) {
                print(e);
              }
            },
            borderRadius: 8,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: TileColor.Green,
            child: CSText(
              "Make Payment",
              textType: TextType.Button,
              textColor: TextColor.White,
            ),
          ),
        ],
      ),
    );
  }
}

class NoLicenseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CSTile(
      onTap: () {
        PopupNotifications.showNotificationDialog(
          context,
          barrierDismissible: true,
          child: UploadLicensePopup(),
        );
      },
      borderRadius: 8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            CupertinoIcons.info,
            color: Colors.blueAccent,
            size: 45,
          ),
          CSText(
            "Your driver account is currently unavailable",
            textType: TextType.H4,
            padding: EdgeInsets.symmetric(vertical: 16),
            textAlign: TextAlign.center,
          ),
          CSText(
            "Tap here to upload an image of your license in order to enable your driver account",
            padding: EdgeInsets.only(top: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class UpdateLicenseWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CSTile(
      onTap: () {
        PopupNotifications.showNotificationDialog(
          context,
          barrierDismissible: true,
          child: UploadLicensePopup(),
        );
      },
      borderRadius: 8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            CupertinoIcons.info,
            color: Colors.blueAccent,
            size: 45,
          ),
          CSText(
            "Your driver account is currently unavailable due to expired license",
            textType: TextType.H4,
            padding: EdgeInsets.symmetric(vertical: 16),
            textAlign: TextAlign.center,
          ),
          CSText(
            "Tap here to upload an image of your renewed license in order to re-enable your driver account",
            padding: EdgeInsets.only(top: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WaitForVerification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CSTile(
      borderRadius: 8,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            CupertinoIcons.info,
            color: Colors.blueAccent,
            size: 45,
          ),
          CSText(
            "Your driver account is currently undergoing verification",
            textType: TextType.H4,
            padding: EdgeInsets.symmetric(vertical: 16),
            textAlign: TextAlign.center,
          ),
          CSText(
            "Please allow 5 minutes to an hour for our staff to review your account. In the meantime, why not register your vehicle?",
            padding: EdgeInsets.only(top: 8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class UploadLicensePopup extends StatefulWidget {
  final bool expired;
  const UploadLicensePopup({
    this.expired = false,
    Key key,
  }) : super(key: key);

  @override
  _UploadLicensePopupState createState() => _UploadLicensePopupState();
}

class _UploadLicensePopupState extends State<UploadLicensePopup> {
  String licenseImage;
  DateTime licenseExpiry;
  saveUrl(String v) {
    setState(() {
      licenseImage = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CSTile(
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CSText(
            "After uploading the image and date, please allow some time for our staff to validate the data. Thank you for your patience.",
            textAlign: TextAlign.center,
            textColor: TextColor.Blue,
          ),
          CSTile(
            padding: EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 92 / 60,
              child: ImageUploadWidget(
                92 / 60,
                saveUrl,
                prompt: "Upload Driver's License Image",
              ),
            ),
          ),
          CSTile(
            onTap: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          new DateTime.now().add(Duration(days: 365 * 10)))
                  .then((value) {
                setState(() {
                  licenseExpiry = value;
                });
              });
            },
            borderRadius: 8,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color:
                licenseExpiry != null ? TileColor.Primary : TileColor.DarkGrey,
            child: CSText(
              licenseExpiry != null
                  ? "${formatDate(licenseExpiry, [
                      MM,
                      " ",
                      dd,
                      ", ",
                      yyyy,
                    ])}"
                  : "Set license expiry date",
              textType: TextType.Button,
              textColor:
                  licenseExpiry != null ? TextColor.White : TextColor.Grey,
            ),
          ),
          if (licenseExpiry != null && licenseImage != null)
            CSTile(
              onTap: () async {
                try {
                  locator<NavigationService>().goBack();
                  showDialog(
                      context: context,
                      builder: (context) => Material(
                          color: Colors.transparent,
                          child: LoadingFullScreenWidget()));
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(locator<AuthService>().currentUser().uid)
                      .update({
                    "licenseExpiry": licenseExpiry,
                    "licenseImage": licenseImage,
                    "userAccess": 110
                  }).then((e) {
                    locator<NavigationService>().goBack();
                  });
                } catch (e) {
                  print(e);
                }
              },
              borderRadius: 8,
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: TileColor.Green,
              child: CSText(
                "SAVE",
                textType: TextType.Button,
                textColor: TextColor.White,
              ),
            )
        ],
      ),
    );
  }
}

class CSMenuButton extends StatelessWidget {
  const CSMenuButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      child: Stack(children: [
        Center(
          child: Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        // Positioned(
        //   right: 6,
        //   top: 8,
        //   child: Icon(
        //     Icons.circle,
        //     size: 8,
        //     color: csStyle.csRed,
        //   ),
        // ),
      ]),
    );
  }
}
