import 'package:carspace/reusable/ImageUploadWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  final bool fromHomeScreen;
  VehicleRegistrationScreen({this.fromHomeScreen});
  @override
  _VehicleRegistrationScreenState createState() => _VehicleRegistrationScreenState(this.fromHomeScreen);
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  bool fromHomeScreen;
  TextEditingController _plateNumberController;
  TextEditingController _vehicleMake;
  TextEditingController _vehicleModel;
  FocusNode _plateNumberFN;
  FocusNode _vehicleMakeFN;
  FocusNode _vehicleModelFN;
  String orImageUrl;
  String crImageUrl;
  String vehicleImageUrl;

  final cache = Hive.box("localCache");
  String pColor;
  int pType;
  List<String> vehicleTypes;
  List<String> colors;
  TextStyle style;
  TextStyle hStyle;

  _VehicleRegistrationScreenState(bool v) {
    this.fromHomeScreen = v != null ? v : false;
  }

  @override
  void initState() {
    super.initState();
    style = TextStyle(fontSize: 14, color: Colors.black87);
    hStyle = TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold);
    vehicleTypes = List<String>.from(cache.get("data")["vehicleTypes"]);
    colors = List<String>.from(cache.get("data")["colors"]);
    pType = 0;
    pColor = "Choose a color";
    _plateNumberController = TextEditingController(text: "");
    _vehicleMake = TextEditingController(text: "");
    _vehicleModel = TextEditingController(text: "");
    _plateNumberFN = new FocusNode();
    _vehicleMakeFN = new FocusNode();
    _vehicleModelFN = new FocusNode();
  }

  @override
  void dispose() {
    _plateNumberFN.dispose();
    _vehicleMakeFN.dispose();
    _vehicleModelFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: themeData.primaryColor,
      bottomNavigationBar: _nextButton(context),
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            fromHomeScreen ? showCancelDialog(context) : backToLogin(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: fromHomeScreen
            ? null
            : [
                Center(
                  child: InkWell(
                    onTap: () {
                      showSkipDialog(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                      child: Text("Skip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0)),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1a237e), Color(0xFF000051)]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  "Vehicle Photo",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: ImageUploadWidget(16 / 9, saveVehicleImage, prompt: "Upload photo of vehicle"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  "Owner's Receipt(OR)",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: ImageUploadWidget(1, saveOR, prompt: "Upload photo of OR"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  "Certification of Registration(CR)",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: ImageUploadWidget(1, saveCR, prompt: "Upload photo of CR"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Vehicle Information",
                                style: hStyle,
                              ),
                              plateNumberInput(),
                              reusableInput(
                                  label: "Brand/make",
                                  hint: "Enter brand/make",
                                  controller: _vehicleMake,
                                  fn: _vehicleMakeFN,
                                  nextFn: _vehicleModelFN),
                              reusableInput(
                                  label: "Model",
                                  hint: "Enter model",
                                  controller: _vehicleModel,
                                  fn: _vehicleModelFN,
                                  nextFn: null),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Type"),
                                    InkWell(
                                      onTap: () {
                                        showMaterialScrollPicker(
                                          context: context,
                                          title: "Select vehicle type",
                                          items: vehicleTypes,
                                          selectedItem: vehicleTypes[pType],
                                          onChanged: (value) => setState(() {
                                            pType = vehicleTypes.indexWhere((v) => v == value);
                                          }),
                                        );
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(8.0),
                                          color: Colors.grey,
                                          child: Text(vehicleTypes[pType])),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Color"),
                                    InkWell(
                                      onTap: () {
                                        showMaterialScrollPicker(
                                          context: context,
                                          title: "Select vehicle type",
                                          items: colors,
                                          selectedItem: pColor,
                                          onChanged: (value) => setState(() {
                                            pColor = value;
                                          }),
                                        );
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(8.0), color: Colors.grey, child: Text(pColor)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding plateNumberInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Plate Number"),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            child: TextField(
              focusNode: _plateNumberFN,
              controller: _plateNumberController,
              style: style,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.black87, fontSize: 14),
                hintText: "Enter plate number",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onEditingComplete: () {
                _plateNumberController.text = _plateNumberController.text.toUpperCase();
                if (_vehicleMakeFN != null)
                  _vehicleMakeFN.requestFocus();
                else
                  _plateNumberFN.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding reusableInput({String label, String hint, TextEditingController controller, FocusNode fn, FocusNode nextFn}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label != null ? label : "Label"),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            child: TextField(
              focusNode: fn,
              controller: controller,
              style: style,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.black87, fontSize: 14),
                hintText: hint != null ? hint : "Hint Text",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onEditingComplete: () {
                controller.text = controller.text.toUpperCase();
                if (nextFn != null)
                  nextFn.requestFocus();
                else
                  fn.unfocus();
              },
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10.0, top: 0),
      child: Container(
        color: Colors.transparent,
        child: FlatButton(
          height: 40,
          color: Color(0xFF534BAE),
          //534bae
          onPressed: () {
            validatePayload(context);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              fromHomeScreen ? "Save" : 'Next',
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

  showCancelDialog(BuildContext context) async {
    if (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Cancel vehicle registration"),
          content: new Text("Are you sure you want to cancel vehicle registration?"),
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
      Navigator.of(context).pop();
    }
  }

  saveVehicleImage(String v) {
    setState(() {
      vehicleImageUrl = v;
    });
  }

  saveOR(String v) {
    setState(() {
      orImageUrl = v;
    });
  }

  saveCR(String v) {
    setState(() {
      crImageUrl = v;
    });
  }

  Future<dynamic> _showConfirmationDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Proceed with registration?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("I confirm that all information below is correct."),
              Container(
                height: 16,
              ),
              Text("Plate Number: ${_plateNumberController.text}"),
              Text("Make: ${_vehicleMake.text}"),
              Text("Model: ${_vehicleModel.text}"),
              Text("Type: ${vehicleTypes[pType]}"),
              Text("Color: $pColor"),
            ],
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void validatePayload(BuildContext context) async {
    if (vehicleImageUrl == null) {
      _showErrorDialog("Please add a photo of your vehicle");
    } else if (orImageUrl == null) {
      _showErrorDialog("Please add a photo of your vehicle OR");
    } else if (crImageUrl == null) {
      _showErrorDialog("Please add a photo of your vehicle CR");
    } else if (_plateNumberController.text.length < 6) {
      _showErrorDialog("Please enter a valid plate number(min 6)");
    } else if (_vehicleMake.text.length < 3) {
      _showErrorDialog("Please enter a valid brand/make(min 3)");
    } else if (_vehicleModel.text.length < 2) {
      _showErrorDialog("Please enter a valid model(min 2)");
    } else if (pType == null) {
      _showErrorDialog("Please enter your vehicle type");
    } else if (pColor == null) {
      _showErrorDialog("Please enter your vehicle color");
    } else {
      var decision = await _showConfirmationDialog();
      if (decision == true) {
        context.read<LoginBloc>().add(AddVehicleEvent(
            plateNumber: _plateNumberController.text,
            type: pType,
            make: _vehicleMake.text,
            model: _vehicleModel.text,
            color: pColor,
            vehicleImage: vehicleImageUrl,
            OR: orImageUrl,
            CR: crImageUrl,
            fromHomeScreen: fromHomeScreen));
        // }
      }
    }
  }
}
