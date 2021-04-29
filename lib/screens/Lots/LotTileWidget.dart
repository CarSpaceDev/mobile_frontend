import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotRepo/lot_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LotImageWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:provider/provider.dart';

class LotTileWidget extends StatelessWidget {
  final Lot lot;
  final Function callback;
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
              url: lot.lotImage[0],
            ),
          ),
          if (lot.rating != null)
            CSTile(
              color: TileColor.None,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.only(top: 4),
              child: SmoothStarRating(
                rating: lot.rating,
                isReadOnly: true,
                size: 32,
                filledIconData: Icons.star,
                halfFilledIconData: Icons.star_half,
                defaultIconData: Icons.star_border,
                starCount: 5,
                allowHalfRating: true,
                spacing: 2.0,
                onRated: null,
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
                  "Available hours ${lot.availableFrom} - ${lot.availableTo}",
                ),
                CSText(
                  "${lot.pricing.toStringAsFixed(2)}/hour",
                )
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
                  "Slots occupied ${lot.capacity-lot.availableSlots}/${lot.capacity}",
                ),
                Row(
                  children: [
                    for (var i = 0; i < lot.capacity; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(CupertinoIcons.car_detailed,
                            color: i < lot.availableSlots ? Theme.of(context).primaryColor : Colors.grey),
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
            )
        ],
      ),
    );
  }
}
