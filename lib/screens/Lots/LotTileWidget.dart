import 'package:carspace/model/Enums.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotRepo/lot_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LotImageWidget.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/screens/Reservations/PartnerReservationScreen.dart';
import 'package:carspace/services/navigation.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:provider/provider.dart';

class LotTileWidget extends StatelessWidget {
  final Lot lot;
  final Function callback;
  final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];
  LotTileWidget({Key key, this.lot, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CSTile(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
      shadow: true,
      child: Column(
        children: <Widget>[
          CSText(
            lot.address.toString(),
            textAlign: TextAlign.center,
            textColor: TextColor.Primary,
            textType: TextType.Button,
            padding: EdgeInsets.only(bottom: 16, right: 16),
          ),
          CSTile(
            color: TileColor.None,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(right: 16),
            child: LotImageWidget(
              url: lot.lotImage,
            ),
          ),
          if (lot.rating != null)
            CSTile(
              color: TileColor.None,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(top: 4, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (lot.parkingType == ParkingType.Both)
                    CSText(
                      "Php ${lot.pricing.toStringAsFixed(2)}/hr ${lot.pricePerDay.toStringAsFixed(2)}/day",
                    ),
                  if (lot.parkingType == ParkingType.Booking)
                    CSText(
                      "Php ${lot.pricing.toStringAsFixed(2)}/hr",
                    ),
                  if (lot.parkingType == ParkingType.Reservation)
                    CSText(
                      "Php ${lot.pricePerDay.toStringAsFixed(2)}/day",
                    ),
                  SmoothStarRating(
                    rating: lot.rating,
                    isReadOnly: true,
                    size: 16,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    defaultIconData: Icons.star_border,
                    starCount: 5,
                    allowHalfRating: true,
                    spacing: 2.0,
                    onRated: null,
                  ),
                ],
              ),
            ),
          CSTile(
            color: TileColor.None,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: 8, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CSText(
                  "${formatDate(DateTime(2020, 1, 1, lot.availableFrom ~/ 100, lot.availableFrom % 100), [
                    H,
                    ":",
                    nn,
                    " ",
                    am
                  ])} to ${formatDate(DateTime(2020, 1, 1, lot.availableTo ~/ 100, lot.availableTo % 100), [
                    H,
                    ":",
                    nn,
                    " ",
                    am
                  ])}",
                  padding: EdgeInsets.only(top: 2),
                ),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Container(
                        margin: EdgeInsets.only(left: 2),
                        width: 16,
                        height: 16,
                        color: lot.availableDays.contains(i) ? Theme.of(context).primaryColor : Colors.grey,
                        child: Center(
                          child: CSText(
                            "${days[i]}",
                            padding: EdgeInsets.only(left: 1, top: 1),
                            textColor: TextColor.White,
                            textType: TextType.Caption,
                          ),
                        ),
                      )
                  ],
                )
              ],
            ),
          ),
          CSTile(
            color: TileColor.None,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.only(top: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CSText(
                  "Slots occupied ${lot.capacity - lot.availableSlots}/${lot.capacity}",
                ),
                Row(
                  children: [
                    for (var i = 0; i < lot.capacity; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(CupertinoIcons.car_detailed,
                            color: i < lot.availableSlots ? Colors.grey : Theme.of(context).primaryColor),
                      ),
                  ],
                )

                // CSText(
                //   "${lot.availableSlots}/${lot.capacity}",
                // )
              ],
            ),
          ),
          if (lot.status == LotStatus.Active || lot.status == LotStatus.Inactive)
            CSTile(
              color: TileColor.None,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CSText(
                    "${lot.status}".replaceAll("LotStatus.", ''),
                  ),
                  Switch(
                      value: lot.status == LotStatus.Active,
                      onChanged: (bool) {
                        if (lot.status == LotStatus.Active) {
                          context.read<LotRepoBloc>().add(UpdateLotStatus(lot: lot, status: LotStatus.Inactive));
                        }
                        if (lot.status == LotStatus.Inactive) {
                          context.read<LotRepoBloc>().add(UpdateLotStatus(lot: lot, status: LotStatus.Active));
                        }
                      })
                ],
              ),
            ),
          if (lot.status != LotStatus.Active && lot.status != LotStatus.Inactive)
            CSTile(
              color: TileColor.None,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CSText(
                    "Status",
                  ),
                  IconButton(icon: Icon(Icons.info, color: Colors.transparent), onPressed: null),
                  InkWell(
                    onTap: () {
                      if (lot.status == LotStatus.Unverified)
                        PopUp.showInfo(
                            context: context,
                            title: "${lot.status}".replaceAll("LotStatus.", ''),
                            body:
                                "It can take up to 45 minutes for a lot to be verified. Please bear with us while we check the documents submitted");
                      if (lot.status == LotStatus.Blocked)
                        PopUp.showInfo(
                            context: context,
                            title: "${lot.status}".replaceAll("LotStatus.", ''),
                            body:
                                "Your lot has dropped below the threshold for ratings. Please contact support at support@carspace.com in order to have it unblocked.");
                    },
                    child: Row(
                      children: [
                        CSText(
                          "${lot.status}".replaceAll("LotStatus.", ''),
                          padding: EdgeInsets.only(top: 2, right: 4),
                        ),
                        Icon(
                          CupertinoIcons.info,
                          size: 16,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (lot.availableSlots < lot.capacity)
            InkWell(
                onTap: () {
                  locator<NavigationService>().pushNavigateToWidget(
                    getPageRoute(
                      PartnerReservationScreen(),
                      RouteSettings(name: "PARTNER-RESERVATIONS"),
                    ),
                  );
                },
                child: CSText(
                  "RESERVATIONS",
                  textType: TextType.Button,
                  textColor: TextColor.Green,
                  padding: EdgeInsets.only(right: 16),
                ))
        ],
      ),
    );
  }
}
