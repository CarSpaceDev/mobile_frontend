import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/blocs/timings/timings_bloc.dart';
import 'package:carspace/model/Enums.dart';
import 'package:carspace/model/Reservation.dart';
import 'package:carspace/repo/reservationRepo/reservation_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:carspace/reusable/LotImageWidget.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/reusable/RatingAndFeedback.dart';
import 'package:carspace/screens/Navigation/DriverNavigationService.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
                return DriverReservationTileWidget(reservation: state.reservations[index]);
              },
            );
          }
          return LoadingFullScreenWidget();
        },
      ),
    );
  }
}

class DriverReservationTileWidget extends StatelessWidget {
  final Reservation reservation;
  final bool disableActions;
  DriverReservationTileWidget({@required this.reservation, this.disableActions = false});
  @override
  Widget build(BuildContext context) {
    return CSTile(
      onTap: () {
        if (!disableActions) DriverReservationActions().showActionsDialog(context, reservation: reservation);
      },
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      shadow: true,
      borderRadius: 8,
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
          if (reservation.userRating == true)
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
                ],
              ),
            ),
          if (reservation.userRating == false)
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
                  if (reservation.reservationStatus == ReservationStatus.Completed)
                    CSText(
                      " (UNRATED)",
                      textType: TextType.Caption,
                      textColor: TextColor.White,
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

class DriverReservationActions {
  showActionsDialog(BuildContext context, {@required Reservation reservation}) {
    PopupNotifications.showNotificationDialog(
      context,
      barrierDismissible: true,
      child: actions(context: context, reservation: reservation),
    );
  }

  Column actions({@required BuildContext context, @required Reservation reservation, bool noPop = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reservation.reservationStatus == ReservationStatus.Active)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  onPressed: () {
                    locator<NavigationService>()
                        .navigatorKey
                        .currentContext
                        .read<TimingsBloc>()
                        .add(StartTest(type: TimingsType.EndBooking));
                    if (reservation.reservationType == ReservationType.Booking)
                      markAsComplete(locator<AuthService>().currentUser().uid, reservation.lotId, reservation.vehicleId,
                          reservation.reservationId, reservation.lotAddress, reservation.partnerId, noPop);
                    else
                      markAsCompleteV2(
                          locator<AuthService>().currentUser().uid,
                          reservation.lotId,
                          reservation.vehicleId,
                          reservation.reservationId,
                          reservation.lotAddress,
                          reservation.partnerId,
                          noPop);
                  },
                  icon: Icon(CupertinoIcons.xmark, color: Colors.redAccent),
                  label: CSText(
                    'END BOOKING',
                    textColor: TextColor.Red,
                    textType: TextType.Button,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  onPressed: () {
                    locator<ApiService>().notifyArrived({
                      "userId": locator<AuthService>().currentUser().uid,
                      "driverName": locator<AuthService>().currentUser().displayName,
                      "vehicleId": reservation.vehicleId,
                      "lotAddress": reservation.lotAddress,
                      "partnerId": reservation.partnerId
                    });
                  },
                  icon: Icon(
                    Icons.car_repair,
                    color: Colors.blueAccent,
                  ),
                  label: CSText(
                    'NOTIFY ARRIVED',
                    textColor: TextColor.Blue,
                    textType: TextType.Button,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton.icon(
                  onPressed: () {
                    if (!noPop) Navigator.of(context).pop();
                    PopupNotifications.showFullScreenLoading(color: Colors.white, prompt: "Loading navigation");
                    locator<ApiService>().notifyOnTheWay({
                      "userId": locator<AuthService>().currentUser().uid,
                      "driverName": locator<AuthService>().currentUser().displayName,
                      "vehicleId": reservation.vehicleId,
                      "lotAddress": reservation.lotAddress,
                      "partnerId": reservation.partnerId
                    }).then((data) {
                      Navigator.of(context).pop();
                    });
                    locator<NavigationService>()
                        .navigatorKey
                        .currentContext
                        .read<GeolocationBloc>()
                        .add(StartGeolocationBroadcast(reservation: reservation));
                    DriverNavigationService(reservation: reservation).navigateViaMapBox();
                  },
                  icon: Icon(
                    Icons.map_outlined,
                    color: Colors.blueAccent,
                  ),
                  label: CSText(
                    'NAVIGATE TO LOT',
                    textColor: TextColor.Blue,
                    textType: TextType.Button,
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
                      if (!noPop) Navigator.of(context).pop();
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
    );
  }

  markAsComplete(String userId, String lotId, String vehicleId, String reservationId, String lotAddress,
      String partnerId, bool noPop) async {
    if (!noPop) locator<NavigationService>().goBack();
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    PopupNotifications.showFullScreenLoading(prompt: "ENDING TRANSACTION", color: Colors.white);
    locator<ApiService>().markAsComplete(body).then((value) {
      locator<NavigationService>()
          .navigatorKey
          .currentContext
          .read<TimingsBloc>()
          .add(EndTest(type: TimingsType.EndBooking));
      locator<NavigationService>().goBack();
    });
  }

  markAsCompleteV2(String userId, String lotId, String vehicleId, String reservationId, String lotAddress,
      String partnerId, bool noPop) async {
    if (!noPop) locator<NavigationService>().goBack();
    var body = ({
      "userId": userId,
      "lotId": lotId,
      "vehicleId": vehicleId,
      "reservationId": reservationId,
      "lotAddress": lotAddress,
      "partnerId": partnerId
    });
    PopupNotifications.showFullScreenLoading(prompt: "ENDING TRANSACTION", color: Colors.white);
    locator<ApiService>().markAsCompleteV2(body).then((value) {
      locator<NavigationService>()
          .navigatorKey
          .currentContext
          .read<TimingsBloc>()
          .add(EndTest(type: TimingsType.EndBooking));
      locator<NavigationService>().goBack();
    });
  }

  rating(BuildContext context, Reservation reservationData, String userId) {
    PopupNotifications.showNotificationDialog(context,
        child: RatingAndFeedback(reservationData, userId, 0), barrierDismissible: true);
  }

  showMessage(BuildContext context, String v) {
    PopUp.showInfo(context: locator<NavigationService>().navigatorKey.currentContext, title: '', body: v);
  }
}
