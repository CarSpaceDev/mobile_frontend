import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/UploadService.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

import '../serviceLocator.dart';

class ImageUploadWidget extends StatefulWidget {
  final String prompt;
  final Function callback;
  final double aspectRatio;
  ImageUploadWidget(this.aspectRatio, this.callback, {this.prompt});
  @override
  _ImageUploadWidgetState createState() => _ImageUploadWidgetState(this.prompt, this.callback, this.aspectRatio);
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  _ImageUploadWidgetState(this.prompt, this.callback, this.aspectRatio);
  File imageFile;
  String imageUrl;
  final double aspectRatio;
  final Function callback;
  final String prompt;
  final picker = ImagePicker();
  final cropKey = GlobalKey<CropState>();
  final UploadService uploadService = locator<UploadService>();
  @override
  Widget build(BuildContext context) {
    return imageUrl == null
        ? FDottedLine(
            color: Colors.black54,
            strokeWidth: 2.0,
            dottedLength: 15.0,
            space: 4.0,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      _showChoiceDialog(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.upload_file,
                            color: Colors.black54,
                          ),
                        ),
                        Text(prompt != null ? prompt : "Upload Image", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : InkWell(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) => LinearProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            onTap: () {
              _showImageViewer(context, true);
            },
          );
  }

  getImageFile() {
    return imageUrl;
  }

  _showWaiting(String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Material(
              color: Colors.transparent,
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          message,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: csTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> _showImageViewer(BuildContext context, bool deleteMode) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(10.0),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Center(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(),
                      Text(
                        deleteMode ? "Delete Image?" : 'Upload Image',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.black,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  Text(
                    deleteMode ? '' : 'Pinch to crop',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  Column(
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: this.aspectRatio,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: deleteMode
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(imageUrl),
                                )
                              : Crop(
                                  image: FileImage(imageFile),
                                  key: cropKey,
                                  aspectRatio: this.aspectRatio,
                                ),
                        ),
                      ),
                      Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: SizedBox(
                          // height: 80,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                deleteMode
                                    ? OutlineButton(
                                        onPressed: () async {
                                          _showWaiting("Deleting Image");
                                          List<Future<dynamic>> batch = [];
                                          batch = [
                                            _deleteTempFile(),
                                            locator<ApiService>().deleteImage({"url": imageUrl})
                                          ];
                                          Future.wait(batch).then((value) {
                                            setState(() {
                                              imageFile = null;
                                              imageUrl = null;
                                            });
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            this.callback(null);
                                          });
                                        },
                                        borderSide: BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red, fontSize: 20),
                                        ),
                                      )
                                    : OutlineButton(
                                        onPressed: () async {
                                          try {
                                            _showWaiting("Uploading Image");
                                            await _cropImage();
                                            await uploadService.uploadItemImage(imageFile.path).then((result) {
                                              setState(() {
                                                imageUrl = result.body["url"];
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              this.callback(result.body["url"]);
                                            });
                                          } catch (e) {
                                            Navigator.pop(context);
                                            _showErrorDialog(e.toString());
                                          }
                                        },
                                        borderSide: BorderSide(color: Colors.green),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Upload',
                                              style: TextStyle(color: Colors.green, fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  //button
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _deleteTempFile() async {
    File existingFile;
    if (await File(getStoragePath(imageFile.path) + 'compressed_.jpg').exists()) {
      existingFile = await File(getStoragePath(imageFile.path) + 'compressed_.jpg').delete();
    }
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      return;
    }
    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: imageFile,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    setState(() {
      imageFile = file;
    });
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Upload Photo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 20.0, right: 8.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                roundedEndButton(context, 'Open Library', true, true, Icons.photo_album, _openLibrary),
                                roundedEndButton(context, 'Take Picture', false, false, Icons.camera, _openCamera),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Expanded roundedEndButton(BuildContext context, String title, bool facingLeft, bool darkMode, IconData iconData, Function onTap) {
    List<Color> theme;
    RoundedRectangleBorder style;
    if (darkMode)
      theme = [Colors.white, Colors.black87];
    else
      theme = [Colors.black87, Colors.white];
    if (facingLeft)
      style = RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
      );
    else
      style = RoundedRectangleBorder(
        side: BorderSide(color: Colors.black87),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      );
    return Expanded(
      child: SizedBox(
        width: 200,
        child: FlatButton(
          onPressed: () => onTap(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, color: theme[0], size: 4 * SizeConfig.imageSizeMultiplier),
              Text(
                title,
                style: TextStyle(color: theme[0], fontSize: 1.5 * SizeConfig.textMultiplier),
              )
            ],
          ),
          shape: style,
          color: theme[1],
        ),
      ),
    );
  }

  _openLibrary(BuildContext context) async {
    imageCache.clear();
    var picture = await picker.getImage(source: ImageSource.gallery);
    if (picture != null) {
      if (await File(getStoragePath(picture.path) + "compressed_.jpg").exists()) {
        await File(getStoragePath(picture.path) + "compressed_.jpg").delete();
      }

      setState(() {
        imageFile = File(picture.path);
      });
      Navigator.of(context).pop();
      _showImageViewer(context, false);
    }
  }

  Future<File> compressImage(PickedFile picture, int imageIndex) async {
    return await FlutterImageCompress.compressAndGetFile(picture.path, getStoragePath(picture.path) + "compressed_" + imageIndex.toString() + '.jpg',
        minWidth: 720, minHeight: 720, quality: 88);
  }

  getStoragePath(String path) {
    var splitPath = path.split('/');
    return path.replaceAll(splitPath[splitPath.length - 1], '');
  }

  _openCamera(BuildContext context) async {
    imageCache.clear();
    var picture = await picker.getImage(source: ImageSource.camera);
    if (picture != null) {
      if (await File(getStoragePath(picture.path) + "compressed_.jpg").exists()) {
        await File(getStoragePath(picture.path) + "compressed_.jpg").delete();
      }
      setState(() {
        imageFile = File(picture.path);
      });
      Navigator.of(context).pop();
      _showImageViewer(context, false);
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(errorMessage.toString()),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
