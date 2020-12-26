import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:fdottedline/fdottedline.dart';
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
  TextEditingController _passwordController;
  TextEditingController _verifyPasswordController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: "");
    _lastNameController = TextEditingController(text: "");
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    _verifyPasswordController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    _firstNameController =
        TextEditingController(text: locator<GlobalData>().heldFirstName);
    _lastNameController =
        TextEditingController(text: locator<GlobalData>().heldLastName);
    _emailController =
        TextEditingController(text: locator<GlobalData>().heldEmail);
    return Scaffold(
        // backgroundColor: themeData.primaryColor,
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
                          child: FDottedLine(
                            color: Colors.black54,
                            strokeWidth: 2.0,
                            dottedLength: 15.0,
                            space: 4.0,
                            child: AspectRatio(
                              aspectRatio: 92 / 60,
                              child: Container(
                                child: Center(
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
                                      Text('Upload photo of license',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )
          ]),
        )
        // body: SingleChildScrollView(
        //   child: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: <Widget>[
        //         Column(
        //           children: <Widget>[
        //             Container(
        //               child: Image.asset(
        //                 'assets/logo/CarSpace.png',
        //                 height: 115,
        //                 width: 115,
        //               ),
        //             ),
        //             Padding(
        //               padding: const EdgeInsets.all(8.0),
        //               child: Center(
        //                 child: Text(
        //                   "let's create your account....",
        //                   style: TextStyle(
        //                       fontFamily: "Champagne & Limousines",
        //                       fontWeight: FontWeight.bold,
        //                       fontSize: 20.0,
        //                       color: Colors.white),
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.symmetric(
        //               vertical: 60.0, horizontal: 20.0),
        //           child: Column(
        //             children: <Widget>[
        //               TextField(
        //                   controller: _emailController,
        //                   style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: Colors.white,
        //                       fontSize: 20),
        //                   decoration: InputDecoration(
        //                       hintText: "Email address",
        //                       hintStyle: TextStyle(
        //                           fontFamily: "Champagne & Limousines",
        //                           fontSize: 16,
        //                           color: Colors.grey),
        //                       enabledBorder: UnderlineInputBorder(
        //                         borderSide: BorderSide(color: Colors.grey),
        //                       ))),
        //               TextField(
        //                   controller: _passwordController,
        //                   obscureText: true,
        //                   style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: Colors.grey,
        //                       fontSize: 20),
        //                   decoration: InputDecoration(
        //                       hintText: "Password",
        //                       hintStyle: TextStyle(
        //                           fontFamily: "Champagne & Limousines",
        //                           fontSize: 16,
        //                           color: Colors.grey),
        //                       enabledBorder: UnderlineInputBorder(
        //                         borderSide: BorderSide(color: Colors.grey),
        //                       ))),
        //               TextField(
        //                   controller: _verifyPasswordController,
        //                   obscureText: true,
        //                   style: TextStyle(
        //                       fontWeight: FontWeight.bold,
        //                       color: Colors.white,
        //                       fontSize: 20),
        //                   decoration: InputDecoration(
        //                       hintText: "Verify password",
        //                       hintStyle: TextStyle(
        //                           fontFamily: "Champagne & Limousines",
        //                           fontSize: 16,
        //                           color: Colors.grey),
        //                       enabledBorder: UnderlineInputBorder(
        //                         borderSide: BorderSide(color: Colors.grey),
        //                       ))),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        child: OutlineButton(
          splashColor: Colors.grey,
          onPressed: () {
            if (_passwordController.text.isEmpty ||
                _verifyPasswordController.text.isEmpty) {
              _showDialog('Password fields must not be empty');
            } else if (_passwordController.text !=
                _verifyPasswordController.text) {
              _showDialog('Password fields must match');
            } else if (_passwordController.text.length <= 5) {
              _showDialog('Password must be at least 6 characters');
            } else if (_emailController.text.isNotEmpty) {
              if (!validateEmail(_emailController.text)) {
                _showDialog('Enter a valid email address');
              }
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          borderSide: BorderSide(color: Colors.white),
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
