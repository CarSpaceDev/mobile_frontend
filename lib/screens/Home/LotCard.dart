import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/model/Lot.dart';
import "package:flutter/material.dart";
import 'package:photo_view/photo_view.dart';

class LotCard extends StatelessWidget {
  final Lot lot;
  final Function callback;
  LotCard({Key key, this.lot, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .15,
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                lot.address.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: InkWell(
                      onTap: () {
                        _showExpandedImage(context);
                      },
                      child: CachedNetworkImage(
                        imageUrl: lot.lotImage[0],
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            LinearProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Available hours " + lot.availableFrom.toString() + " - " + lot.availableTo.toString(),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.location_on, size: 16),
                      Text(
                        '${lot.distance.toStringAsFixed(2)} km',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  InkWell(onTap: callback, child: Text("View more details", style: TextStyle(fontSize: 16))),
                  Text("${lot.pricing.toStringAsFixed(2)}/hour", style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showExpandedImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: 8),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PhotoView(
                    backgroundDecoration: BoxDecoration(color: Colors.transparent),
                    // imageProvider: CachedNetworkImage(
                    //   imageUrl: lot.lotImage[0],
                    //   progressIndicatorBuilder: (context, url, downloadProgress) => LinearProgressIndicator(value: downloadProgress.progress),
                    //   errorWidget: (context, url, error) => Icon(Icons.error),
                    // ),
                    imageProvider: CachedNetworkImageProvider(lot.lotImage[0]),
                  ),
                ),
              ),
            ));
  }
}
