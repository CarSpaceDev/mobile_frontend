import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:carspace/reusable/ImageUploadWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController _emailController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _licenseExpiryController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl;
  TextStyle inputStyle;
  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      var name = _auth.currentUser.displayName.split(" ");
      _firstNameController = TextEditingController(text: name[0]);
      _lastNameController =
          TextEditingController(text: name[1] != null ? name[1] : "");
      _emailController = TextEditingController(text: _auth.currentUser.email);
      _licenseExpiryController = TextEditingController(text: "");
    } else {
      print("Not a google user registration");
      _firstNameController = TextEditingController(text: "");
      _lastNameController = TextEditingController(text: "");
      _emailController = TextEditingController(text: "");
      _licenseExpiryController = TextEditingController(text: "");
    }
    inputStyle = TextStyle(
        fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: arrowForwardAppBarWidget(context, "Register account", () {
        navigateToEula(context);
      }),
      bottomNavigationBar: SizedBox(child: _nextButton()),
      body: SafeArea(
        child: Stack(children: [
          Positioned(
            child: Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0)),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a237e), Color(0xFF000051)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, left: 8.0, right: 8.0, bottom: 8.0),
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
                        child: AspectRatio(
                          aspectRatio: 92 / 60,
                          child: ImageUploadWidget(92 / 60, saveUrl,
                              prompt: "Upload photo of license"),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Text('Driver\'s Information',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                          ),
                          reusableInput(
                              controller: _firstNameController,
                              hintText: "First Name*"),
                          reusableInput(
                              controller: _lastNameController,
                              hintText: "Last Name*"),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _emailController,
                              onChanged: (data) {
                                print(validateEmail(data));
                              },
                              style: inputStyle,
                              decoration: InputDecoration(
                                hintText: "Email address*",
                                hintStyle: inputStyle,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _licenseExpiryController,
                              keyboardType: TextInputType.number,
                              onTap: () async {
                                showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: new DateTime.now()
                                            .add(Duration(days: 365 * 10)))
                                    .then((value) {
                                  _licenseExpiryController.text =
                                      value.toString().substring(0, 10);
                                });
                              },
                              style: inputStyle,
                              decoration: InputDecoration(
                                hintText: "License expiry*",
                                hintStyle: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Padding reusableInput({
    TextEditingController controller,
    String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
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

  saveUrl(String v) {
    print("Saved url");
    setState(() {
      imageUrl = v;
    });
    print(imageUrl);
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
      child: Container(
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () {
            // if (_passwordController.text.isEmpty ||
            //     _verifyPasswordController.text.isEmpty) {
            //   _showDialog('Password fields must not be empty');
            // } else if (_passwordController.text !=
            //     _verifyPasswordController.text) {
            //   _showDialog('Password fields must match');
            // } else if (_passwordController.text.length <= 5) {
            //   _showDialog('Password must be at least 6 characters');
            // } else if (_emailController.text.isNotEmpty) {
            //   if (!validateEmail(_emailController.text)) {
            //     _showDialog('Enter a valid email address');
            //   }
            // }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
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
      ),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void _showDialog(String errorMessage) {
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

  navigateToEula(BuildContext context) {
    print('Navigate to Eula');
    context.read<LoginBloc>().add(NavigateToEulaEvent());
  }

  testSubmit(BuildContext context) {
    print('testSubmit');
    context.read<LoginBloc>().add(SubmitRegistrationEvent(_emailController.text,
        _firstNameController.text, _lastNameController.text));
  }
}
