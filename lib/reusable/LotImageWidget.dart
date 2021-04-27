import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'PopupNotifications.dart';

class LotImageWidget extends StatelessWidget {
  final String lotUid;
  final double aspectRatio;
  LotImageWidget({@required this.lotUid, this.aspectRatio = 16 / 9});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: FutureBuilder(
          future: FirebaseFirestore.instance.collection("lots").doc(lotUid).get(),
          builder: (BuildContext context, result) {
            if (result.hasData)
              return InkWell(
                onTap: () {
                  PopupNotifications.showNotificationDialog(context,
                      barrierDismissible: true,
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: Colors.black12,
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: result.data.data()['lotImage'],
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    LinearProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.black12,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: result.data.data()['lotImage'],
                        progressIndicatorBuilder: (context, url, downloadProgress) =>
                            LinearProgressIndicator(value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              );
            return Container();
          }),
    );
  }
}
