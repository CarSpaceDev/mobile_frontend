import 'package:carspace/model/Enums.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/repo/reservationRepo/reservation_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:carspace/reusable/LotImageWidget.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/reusable/RatingAndFeedback.dart';
import 'package:carspace/screens/DriverScreens/Navigation/DriverNavigationService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverReservationScreen extends StatefulWidget {
  @override
  _DriverReservationScreenState createState() => _DriverReservationScreenState();
}

class _DriverReservationScreenState extends State<DriverReservationScreen> {
  @override
  void initState() {
    locator<NavigationService>()
        .navigatorKey
        .currentContext
        .bloc<ReservationRepoBloc>()
        .add(InitializeReservationRepo(uid: locator<AuthService>().currentUser().uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('Reservations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context
                  .bloc<ReservationRepoBloc>()
                  .add(InitializeReservationRepo(uid: locator<AuthService>().currentUser().uid));
            },
          )
        ],
      ),
      body: BlocBuilder<ReservationRepoBloc, ReservationRepoState>(
        builder: (BuildContext context, state) {
          if (state is ReservationRepoReady) {
            if (state.reservations.isEmpty) {
              return Center(
                child: CSText("No reservations at the moment"),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.reservations.length,
              itemBuilder: (BuildContext context, index) {
                return ReservationTileWidget(reservation: state.reservations[index]);
              },
            );
          }
          return LoadingFullScreenWidget();
        },
      ),
    );
  }
}

class ReservationTileWidget extends StatelessWidget {
  final Reservation reservation;
  ReservationTileWidget({@required this.reservation});
  @override
  Widget build(BuildContext context) {
    return CSTile(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shadow: true,
      borderRadius: 8,
      child: InkWell(
        onTap: () {
          _showActionsDialog(context, reservation: reservation);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(flex: 1, child: LotImageWidget(lotUid: reservation.lotId)),
                Flexible(
                  flex: 2,
                  child: CSText(
                    reservation.lotAddress,
                    textType: TextType.H5Bold,
                    padding: EdgeInsets.only(left: 8),
                  ),
                ),
              ],
            ),
            CSTile(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.zero,
              color: TileColor.None,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: RichText(
                      text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                        TextSpan(text: 'Date Placed: ', style: TextStyle(color: Colors.grey)),
                        TextSpan(
                          text: "${formatDate(reservation.dateCreated, [
                            MM,
                            " ",
                            dd,
                            ", ",
                            yyyy,
                            " ",
                            h,
                            ":",
                            nn
                          ])} ${reservation.dateCreated.hour < 12 ? "AM" : "PM"}",
                        )
                      ]),
                    ),
                  ),
                  if (reservation.dateUpdated != reservation.dateCreated)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: RichText(
                        text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                          TextSpan(text: 'Date Exited: ', style: TextStyle(color: Colors.grey)),
                          TextSpan(
                            text: "${formatDate(reservation.dateUpdated, [
                              MM,
                              " ",
                              dd,
                              ", ",
                              yyyy,
                              " ",
                              h,
                              ":",
                              nn
                            ])} ${reservation.dateUpdated.hour < 12 ? "AM" : "PM"}",
                          )
                        ]),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: RichText(
                      text: TextSpan(style: TextStyle(color: Colors.black), children: <TextSpan>[
                        TextSpan(text: 'Vehicle: ', style: TextStyle(color: Colors.grey)),
                        TextSpan(text: reservation.vehicleId)
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            CSTile(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: EdgeInsets.zero,
              color: reservation.reservationStatus == ReservationStatus.Active ? TileColor.Green : TileColor.Secondary,
              shadow: true,
              borderRadius: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CSText(
                    "${reservation.reservationStatus == ReservationStatus.Active ? "Active" : "Completed"}"
                        .toUpperCase(),
                    textType: TextType.Caption,
                    textColor: TextColor.White,
                  ),
                  CSText(
                    " ${reservation.reservationType}".replaceAll("ReservationType.", '').toUpperCase(),
                    textType: TextType.Caption,
                    textColor: TextColor.White,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _showActionsDialog(BuildContext context, {@required Reservation reservation}) {
    PopupNotifications.showNotificationDialog(
      context,
      barrierDismissible: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reservation.reservationStatus == ReservationStatus.Active)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      locator<NavigationService>().goBack();
                      DriverNavigationService(reservation: reservation).navigateViaMapBox();
                    },
                    icon: Icon(
                      Icons.map_outlined,
                      color: Colors.blueAccent,
                    ),
                    label: Text('Navigate to Lot', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      onTheWay(
                          locator<AuthService>().currentUser().uid,
                          locator<AuthService>().currentUser().displayName,
                          reservation.vehicleId,
                          reservation.lotAddress,
                          reservation.partnerId);
                    },
                    icon: Icon(
                      Icons.chat,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Notify on the way',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      arrived(
                          locator<AuthService>().currentUser().uid,
                          locator<AuthService>().currentUser().displayName,
                          reservation.vehicleId,
                          reservation.lotAddress,
                          reservation.partnerId);
                    },
                    icon: Icon(
                      Icons.car_repair,
                      color: Colors.blueAccent,
                    ),
                    label: Text(
                      'Notify arrived',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    onPressed: () {
                      if (reservation.reservationType == ReservationType.Booking)
                        markAsComplete(locator<AuthService>().currentUser().uid, reservation.lotId,
                            reservation.vehicleId, reservation.uid, reservation.lotAddress, reservation.partnerId);
                      else
                        markAsCompleteV2(locator<AuthService>().currentUser().uid, reservation.lotId,
                            reservation.vehicleId, reservation.uid, reservation.lotAddress, reservation.partnerId);
                    },
                    icon: Icon(Icons.check, color: Colors.redAccent),
                    label: Text(
                      'Mark as Complete',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          if (reservation.reservationStatus != ReservationStatus.Active)
            Column(
              children: [
                if (reservation.userRating == false)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        rating(context, reservation, locator<AuthService>().currentUser().uid);
                      },
                      icon: Icon(
                        Icons.car_repair,
                        color: Colors.blueAccent,
                      ),
                      label: Text(
                        'Give rating and feedback',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                if (reservation.userRating)
                  CSTile(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('You have already rated this transaction', style: TextStyle(color: Colors.blueAccent)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  markAsComplete(
      String userId, String lotId, String vehicleId, String reservationId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().markAsComplete(body).then((data) {
      showMessage(data.body);
    });
  }

  markAsCompleteV2(
      String userId, String lotId, String vehicleId, String reservationId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().markAsCompleteV2(body).then((data) {
      showMessage(data.body);
    });
  }

  onTheWay(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "driverName": driverName,
      "vehicleId": vehicleId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().notifyOnTheWay(body).then((data) {
      showMessage("Lot owner notified");
    });
  }

  arrived(String userId, String driverName, String vehicleId, String lotAddress, String partnerId) async {
    var body = ({
      "userId": userId,
      "driverName": driverName,
      "vehicleId": vehicleId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    await locator<ApiService>().notifyArrived(body).then((data) {
      showMessage("Lot owner notified");
    });
  }

  rating(BuildContext context, Reservation reservationData, String userId) {
    PopupNotifications.showNotificationDialog(context,
        child: RatingAndFeedback(reservationData, userId, 0), barrierDismissible: true);
  }

  showMessage(String v) {
    showDialog(
        context: locator<NavigationService>().navigatorKey.currentContext,
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
                      style: TextStyle(height: 5, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    locator<NavigationService>().goBack();
                    locator<NavigationService>().pushNavigateTo(Reservations);
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  void showError({@required String error}) {
    showDialog(
        context: locator<NavigationService>().navigatorKey.currentContext,
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
}
