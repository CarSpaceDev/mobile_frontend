import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:carspace/reusable/ImageUploadWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';
import '../../serviceLocator.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _emailController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _licenseExpiryController;
  TextEditingController _passwordController;
  TextEditingController _passwordConfirmController;
  FocusNode _firstNameFN;
  FocusNode _lastNameFN;
  FocusNode _pass1FN;
  FocusNode _pass2FN;
  FocusNode _emailFN;
  FocusNode _licenseExpiryFN;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl;
  TextStyle inputStyle;
  String gUid;
  @override
  void initState() {
    super.initState();
    _firstNameFN = new FocusNode();
    _lastNameFN = new FocusNode();
    _pass1FN = new FocusNode();
    _pass2FN = new FocusNode();
    _emailFN = new FocusNode();
    _licenseExpiryFN = new FocusNode();
    if (_auth.currentUser != null) {
      gUid = _auth.currentUser.uid;
      var name = _auth.currentUser.displayName.split(" ");
      _firstNameController = TextEditingController(text: name[0]);
      _lastNameController = TextEditingController(text: name[1] != null ? name[1] : "");
      _emailController = TextEditingController(text: _auth.currentUser.email);
      _licenseExpiryController = TextEditingController(text: "");
    } else {
      _firstNameController = TextEditingController(text: "");
      _lastNameController = TextEditingController(text: "");
      _emailController = TextEditingController(text: "");
      _licenseExpiryController = TextEditingController(text: "");
      _passwordController = TextEditingController(text: "");
      _passwordConfirmController = TextEditingController(text: "");
    }
    inputStyle = TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold);
  }

  @override
  void dispose() {
    _firstNameFN.dispose();
    _lastNameFN.dispose();
    _pass1FN.dispose();
    _pass2FN.dispose();
    _emailFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: arrowForwardAppBarWidget(context, "Register account", () {
        restartRegistration(context);
      }),
      bottomNavigationBar: SizedBox(child: _nextButton()),
      body: SafeArea(
        child: Stack(children: [
          Positioned(
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0)),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1a237e), Color(0xFF000051)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Column(children: [
                  licenseUploadDetails(context),
                  gUid != null ? driverInformationWOPass() : driverInformationWPass(),
                ]),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Card driverInformationWPass() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text('Driver\'s Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            reusableInput(controller: _firstNameController, hintText: "First Name*", fn: _firstNameFN, nextFn: _lastNameFN),
            reusableInput(controller: _lastNameController, hintText: "Last Name*", fn: _lastNameFN, nextFn: _emailFN),
            emailInput(controller: _emailController, hintText: "Email address*", fn: _emailFN, nextFn: _pass1FN),
            reusableInput(controller: _passwordController, hintText: "Password*", fn: _pass1FN, nextFn: _pass2FN, password: true),
            reusableInput(controller: _passwordConfirmController, hintText: "Confirm Password*", fn: _pass2FN, password: true),
          ],
        ),
      ),
    );
  }

  Card driverInformationWOPass() {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text('Driver\'s Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
            reusableInput(controller: _firstNameController, hintText: "First Name*", fn: _firstNameFN, nextFn: _lastNameFN),
            reusableInput(controller: _lastNameController, hintText: "Last Name*", fn: _lastNameFN),
            reusableInput(controller: _emailController, hintText: "Email address*", enabled: gUid != null ? false : true),
          ],
        ),
      ),
    );
  }

  Padding licenseUploadDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 92 / 60,
                child: ImageUploadWidget(92 / 60, saveUrl, prompt: "Upload photo of license"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: TextField(
                controller: _licenseExpiryController,
                focusNode: _licenseExpiryFN,
                keyboardType: TextInputType.number,
                onEditingComplete: () {
                  _firstNameFN.requestFocus();
                },
                onTap: () async {
                  setExpiry(context);
                },
                style: inputStyle,
                decoration: InputDecoration(
                  hintText: "License expiry*",
                  hintStyle: TextStyle(fontSize: 16, color: Colors.black54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void setExpiry(BuildContext context) {
    showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: new DateTime.now().add(Duration(days: 365 * 10)))
        .then((value) {
      _licenseExpiryController.text = value.toString().substring(0, 10);
    });
  }

  Padding reusableInput({TextEditingController controller, String hintText, bool enabled, FocusNode fn, FocusNode nextFn, bool password}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        obscureText: password == null ? false : password,
        focusNode: fn != null ? fn : null,
        enabled: enabled != null ? enabled : true,
        onEditingComplete: () {
          if (nextFn != null)
            nextFn.requestFocus();
          else
            fn.unfocus();
        },
        controller: controller,
        style: inputStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: inputStyle,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Padding emailInput({TextEditingController controller, String hintText, bool enabled, FocusNode fn, FocusNode nextFn}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        focusNode: fn != null ? fn : null,
        enabled: enabled != null ? enabled : true,
        controller: controller,
        onEditingComplete: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: themeData.primaryColor,
                      ),
                    ),
                  ));
          locator<ApiService>().checkEmailUsage(email: controller.text).then((value) {
            if (value.body["data"]) {
              Navigator.of(context).pop();
              _showErrorDialog("This email is already in use");
              controller.text = "";
            } else {
              if (nextFn != null)
                nextFn.requestFocus();
              else
                fn.unfocus();
              Navigator.of(context).pop();
            }
          });
        },
        style: inputStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: inputStyle,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  saveUrl(String v) {
    setState(() {
      imageUrl = v;
    });
    if (v != null) setExpiry(context);
  }

  Widget _nextButton() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          submitData(context);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => AddVehicle()),
          // );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        borderSide: BorderSide(color: Colors.black),
        child: Text(
          'Save',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
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

  Future<dynamic> _showConfirmationDialog() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Proceed with registration?"),
          content: new Text("I confirm that all information entered is correct."),
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

  restartRegistration(BuildContext context) {
    context.read<LoginBloc>().add(RestartLoginEvent());
  }

  submitData(BuildContext context) async {
    if (validateData()) {
      var response = await _showConfirmationDialog();
      if (response) {
        RegistrationPayload payload;
        //case 1 - google type register
        if (gUid != null) {
          payload = new RegistrationPayload(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              licenseImage: imageUrl,
              licenseExpiry: _licenseExpiryController.text,
              gUid: gUid);
        } else {
          //case 2 - email/pass type register
          payload = new RegistrationPayload(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              licenseImage: imageUrl,
              licenseExpiry: _licenseExpiryController.text);
        }
        context.read<LoginBloc>().add(SubmitRegistrationEvent(payload));
      } else {}
    }
  }

  bool validateData() {
    if (gUid != null) {
      //check for license data
      if (imageUrl == null) {
        _showErrorDialog('Add a photo of your license');
        return false;
      } else if (_licenseExpiryController.text.isEmpty) {
        _showErrorDialog('Please enter expiry date for license');
        return false;
      } else if (_firstNameController.text.isEmpty) {
        _showErrorDialog('Please enter your first name');
        return false;
      } else if (_lastNameController.text.isEmpty) {
        _showErrorDialog('Please enter your last name');
        return false;
      }
      return true;
    }
    //non google registry
    else {
      if (imageUrl == null) {
        _showErrorDialog('Add a photo of your license');
        return false;
      } else if (_licenseExpiryController.text.isEmpty) {
        _showErrorDialog('Please enter expiry date for license');
        return false;
      } else if (_firstNameController.text.isEmpty) {
        _showErrorDialog('Please enter your first name');
        return false;
      } else if (_lastNameController.text.isEmpty) {
        _showErrorDialog('Please enter your first name');
        return false;
      } else if (_passwordController.text.isEmpty || _passwordConfirmController.text.isEmpty) {
        _showErrorDialog('Password fields must not be empty');
        return false;
      } else if (_passwordController.text != _passwordConfirmController.text) {
        _showErrorDialog('Password fields must match');
        return false;
      } else if (_passwordController.text.length <= 5) {
        _showErrorDialog('Password must be at least 6 characters');
        return false;
      } else if (_emailController.text.isNotEmpty) {
        if (!validateEmail(_emailController.text)) {
          _showErrorDialog('Enter a valid email address');
          return false;
        }
      } else if (_emailController.text.isEmpty) {
        _showErrorDialog('Please enter an email');
        return false;
      }
      return true;
    }
  }
}

class RegistrationPayload {
  String firstName;
  String lastName;
  String email;
  String password;
  String licenseImage;
  DateTime licenseExpiry;
  String gUid;
  RegistrationPayload({this.firstName, this.lastName, this.email, this.password, this.licenseImage, String licenseExpiry, this.gUid}) {
    this.licenseExpiry = DateTime.parse(licenseExpiry);
  }

  toJson() {
    return {
      "uid": this.gUid,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "emailAddress": this.email,
      "password": this.password,
      "licenseImage": this.licenseImage,
      "licenseExpiry": this.licenseExpiry.toIso8601String(),
    };
  }
}
