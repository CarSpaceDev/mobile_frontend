import 'dart:io';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hive/hive.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  @override
  _VehicleRegistrationScreenState createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  TextEditingController _plateNumberController;
  final cache = Hive.box("localCache");
  final picker = ImagePicker();
  String pColor;
  int pType;
  List<File> images = [null, null];
  final cropKey = GlobalKey<CropState>();
  List<String> vehicleTypes;
  List<String> colors;
  TextStyle style = TextStyle(fontSize: 20, color: Colors.white);
  @override
  void initState() {
    super.initState();
    vehicleTypes = List<String>.from(cache.get("data")["vehicleTypes"]);
    colors = List<String>.from(cache.get("data")["colors"]);
    _plateNumberController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      bottomNavigationBar: _nextButton(context),
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            backToLogin(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          Center(
            child: InkWell(
              onTap: () {
                showSkipDialog(context);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Text("Skip",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          "CarSpace",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Let's add your vehicle",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        images[0] == null
                            ? IconButton(
                                iconSize: 120,
                                color: Colors.white,
                                icon: Icon(Icons.image),
                                onPressed: () {
                                  _showChoiceDialog(context, 0);
                                },
                              )
                            : InkWell(
                                onTap: () {
                                  _showImageViewer(context, 0);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: Image.file(images[0])),
                                ),
                              ),
                        Text(
                          "OR",
                          style: style,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        images[1] == null
                            ? IconButton(
                                iconSize: 120,
                                color: Colors.white,
                                icon: Icon(Icons.image),
                                onPressed: () {
                                  _showChoiceDialog(context, 1);
                                },
                              )
                            : InkWell(
                                onTap: () {
                                  _showImageViewer(context, 1);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: Image.file(images[1])),
                                ),
                              ),
                        Text(
                          "CR",
                          style: style,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 35.0),
              Text(
                "Plate Number",
                style: style,
              ),
              TextField(
                controller: _plateNumberController,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onEditingComplete: () {
                  _plateNumberController.text =
                      _plateNumberController.text.toUpperCase();
                },
              ),
              Text(
                "Type",
                style: style,
              ),
              DropdownButton<int>(
                key: UniqueKey(),
                value: pType,
                style: TextStyle(color: Colors.indigo),
                selectedItemBuilder: (BuildContext context) {
                  return vehicleTypes.map((String value) {
                    return Text(
                      value,
                      style: style,
                    );
                  }).toList();
                },
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: Colors.white,
                ),
                onChanged: (int newValue) {
                  print(newValue);
                  setState(() {
                    pType = newValue;
                  });
                },
                items: vehicleTypes.map<DropdownMenuItem<int>>((String value) {
                  return DropdownMenuItem<int>(
                    value: vehicleTypes.indexOf(value),
                    child: Text(value),
                  );
                }).toList(),
              ),
              Text(
                "Color",
                style: style,
              ),
              DropdownButton<String>(
                key: UniqueKey(),
                value: pColor,
                style: TextStyle(color: Colors.indigo),
                selectedItemBuilder: (BuildContext context) {
                  return colors.map((String value) {
                    return Text(
                      value,
                      style: style,
                    );
                  }).toList();
                },
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 1,
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  print(newValue);
                  setState(() {
                    pColor = newValue;
                  });
                },
                items: colors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showImageViewer(BuildContext context, int imageIndex) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        padding: EdgeInsets.all(10.0),
        child: Material(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
                        'Upload Image',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
                  Text(
                    'Pinch to crop',
                    style: TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20),
                        width: SizeConfig.widthMultiplier * 90,
                        height: SizeConfig.widthMultiplier * 90,
                        child: Crop(
                          image: FileImage(images[imageIndex]),
                          key: cropKey,
                          aspectRatio: 1 / 1,
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
                                OutlineButton(
                                  onPressed: () async {
                                    await _deleteTempFile(imageIndex);
                                    setState(() {
                                      images[imageIndex] = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  borderSide: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 20),
                                  ),
                                ),
                                OutlineButton(
                                  onPressed: () {
                                    _cropImage(images[imageIndex], imageIndex);
                                    Navigator.pop(context);
                                  },
                                  borderSide: BorderSide(color: Colors.green),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Save changes',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 20),
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

  _deleteTempFile(int imageIndex) async {
    File existingFile;
    if (await File(getStoragePath(images[imageIndex].path) +
            'compressed_' +
            imageIndex.toString() +
            '.jpg')
        .exists()) {
      existingFile = await File(getStoragePath(images[imageIndex].path) +
              'compressed_' +
              imageIndex.toString() +
              '.jpg')
          .delete();
      print("Deleting temp compressed file: " + existingFile.toString());
    }
  }

  Future<void> _cropImage(File image, int index) async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      return;
    }
    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: image,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    setState(() {
      images[index] = file;
    });
  }

  Future<void> _showChoiceDialog(BuildContext context, int imageIndex) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 20.0, right: 8.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                roundedEndButton(
                                    context,
                                    'Open Library',
                                    true,
                                    true,
                                    Icons.photo_album,
                                    _openLibrary,
                                    imageIndex),
                                roundedEndButton(
                                    context,
                                    'Take Picture',
                                    false,
                                    false,
                                    Icons.camera,
                                    _openCamera,
                                    imageIndex),
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

  Expanded roundedEndButton(BuildContext context, String title, bool facingLeft,
      bool darkMode, IconData iconData, Function onTap, int imageIndex) {
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
          onPressed: () => onTap(context, imageIndex),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData,
                  color: theme[0], size: 4 * SizeConfig.imageSizeMultiplier),
              Text(
                title,
                style: TextStyle(
                    color: theme[0], fontSize: 1.5 * SizeConfig.textMultiplier),
              )
            ],
          ),
          shape: style,
          color: theme[1],
        ),
      ),
    );
  }

  _openLibrary(BuildContext context, int imageIndex) async {
    imageCache.clear();
    var picture = await picker.getImage(source: ImageSource.gallery);
    if (picture != null) {
      if (await File(getStoragePath(picture.path) +
              "compressed_" +
              imageIndex.toString() +
              '.jpg')
          .exists()) {
        print("Old compressed file" +
            "compressed_" +
            imageIndex.toString() +
            '.jpg' +
            " exists, deleting");
        await File(getStoragePath(picture.path) +
                "compressed_" +
                imageIndex.toString() +
                '.jpg')
            .delete();
      }
    }
    // File result = await compressImage(picture, imageIndex);
    setState(() {
      images[imageIndex] = File(picture.path);
    });
    Navigator.of(context).pop();
    _showImageViewer(context, imageIndex);
  }

  Future<File> compressImage(PickedFile picture, int imageIndex) async {
    return await FlutterImageCompress.compressAndGetFile(
        picture.path,
        getStoragePath(picture.path) +
            "compressed_" +
            imageIndex.toString() +
            '.jpg',
        minWidth: 720,
        minHeight: 720,
        quality: 88);
  }

  getStoragePath(String path) {
    var splitPath = path.split('/');
    return path.replaceAll(splitPath[splitPath.length - 1], '');
  }

  _openCamera(BuildContext context, int imageIndex) async {
    var picture = await picker.getImage(source: ImageSource.camera);
    if (picture != null) if (await File(getStoragePath(picture.path) +
            "compressed_" +
            imageIndex.toString() +
            '.jpg')
        .exists()) {
      print("Old compressed file" +
          "compressed_" +
          imageIndex.toString() +
          '.jpg' +
          " exists, deleting");
      await File(getStoragePath(picture.path) +
              "compressed_" +
              imageIndex.toString() +
              '.jpg')
          .delete();
    }
    setState(() {
      images[imageIndex] = File(picture.path);
    });
    Navigator.of(context).pop();
    _showImageViewer(context, imageIndex);
  }

  List<DropdownMenuItem<int>> typeOptions() {
    List<DropdownMenuItem<int>> result = [];
    List<dynamic> types = cache.get("data")["vehicleTypes"];
    types.forEach((element) {
      result.add(
        DropdownMenuItem<int>(
          value: result.length,
          child: Text(
            element,
            style: style,
          ),
        ),
      );
    });
    return result;
  }

  List<DropdownMenuItem<String>> colorOptions() {
    List<DropdownMenuItem<String>> result = [];
    List<dynamic> colors = cache.get("data")["colors"];
    colors.forEach((element) {
      result.add(
        DropdownMenuItem<String>(
          value: element,
          child: Text(
            element,
            style: style,
          ),
        ),
      );
    });
    return result;
  }

  Widget _nextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
      child: Container(
        child: FlatButton(
          height: 40,
          color: Color(0xFF534BAE), //534bae
          onPressed: () {
            validatePayload(context);
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Next',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
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

  backToLogin(BuildContext context) {
    print('Back to login');
    context.read<LoginBloc>().add(RestartLoginEvent());
  }

  showSkipDialog(BuildContext context) async {
    if (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Skip vehicle registration"),
          content: new Text(
              "Are you sure you want to skip vehicle registration? You cannot make reservations until you do."),
          actions: <Widget>[
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: new Text("Sure"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    )) {
      context.read<LoginBloc>().add(SkipVehicleAddEvent());
    }
  }

  void validatePayload(BuildContext context) {
    if (images[0] == null) {
      _showErrorDialog("Please add a picture of your vehicle OR");
    } else if (images[1] == null) {
      _showErrorDialog("Please add a picture of your vehicle CR");
    } else if (_plateNumberController.text.length < 6) {
      _showErrorDialog("Please enter a valid plate number");
    } else if (pType == null) {
      _showErrorDialog("Please enter your vehicle type");
    } else if (pColor == null) {
      _showErrorDialog("Please enter your vehicle color");
    } else {
      print({
        "OR": images[0].path,
        "CR": images[1].path,
        "plateNumber": _plateNumberController.text,
        "type": pType,
        "color": pColor
      });
      context.read<LoginBloc>().add(AddVehicleEvent(
          plateNumber: _plateNumberController.text,
          type: pType,
          color: pColor,
          OR: images[0].path,
          CR: images[1].path));
    }
  }
}
