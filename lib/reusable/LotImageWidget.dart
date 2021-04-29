import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'PopupNotifications.dart';

class LotImageWidget extends StatelessWidget {
  final String lotUid;
  final double aspectRatio;
  final String url;
  LotImageWidget({@required this.lotUid, this.aspectRatio = 16 / 9, this.url});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: url == null
          ? FutureBuilder(
              future: FirebaseFirestore.instance.collection("lots").doc(lotUid).get(),
              builder: (BuildContext context, result) {
                if (result.hasData)
                  return InkWell(
                    onTap: () {
                      PopupNotifications.showNotificationDialog(context,
                          barrierDismissible: true,
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Container(
                              color: Colors.black12,
                              child: Center(
                                child: PhotoView(
                                  backgroundDecoration: BoxDecoration(color: Colors.transparent),
                                  imageProvider: CachedNetworkImageProvider(result.data.data()['lotImage']),
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
              })
          : InkWell(
              onTap: () {
                PopupNotifications.showNotificationDialog(
                  context,
                  barrierDismissible: true,
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Container(
                      color: Colors.black12,
                      child: Center(
                        child: PhotoView(
                          backgroundDecoration: BoxDecoration(color: Colors.transparent),
                          imageProvider: CachedNetworkImageProvider(url),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black12,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
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
