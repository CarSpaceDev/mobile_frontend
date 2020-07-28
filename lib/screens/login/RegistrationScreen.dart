import 'package:carspace/resusables/AppBarLayout.dart';
import 'package:flutter/material.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:provider/provider.dart';
import 'login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _firstNameController = TextEditingController(
        text: Provider.of<GlobalData>(context).heldFirstName);
    _lastNameController = TextEditingController(
        text: Provider.of<GlobalData>(context).heldLastName);
    _emailController =
        TextEditingController(text: Provider.of<GlobalData>(context).heldEmail);
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      appBar: arrowForwardAppBarWidget(context, "Register account", () {
        navigateToEula(context);
      }),
      bottomNavigationBar: SizedBox(child: _nextButton()),
      body: SingleChildScrollView(
        child: Center(
          child: Column(  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'assets/logo/CarSpace.png',
                      height: 115,
                      width: 115,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "let's create your account....",
                        style: TextStyle(
                            fontFamily: "Champagne & Limousines",
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
                child: Column(
                  children: <Widget>[
                    TextField(
                        controller: _emailController,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20),
                        decoration: InputDecoration(
                            hintText: "Email address",
                            hintStyle: TextStyle(
                                fontFamily: "Champagne & Limousines",
                                fontSize: 16,
                                color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ))),
                    TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 20),
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(
                                fontFamily: "Champagne & Limousines",
                                fontSize: 16,
                                color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ))),
                    TextField(
                        controller: _verifyPasswordController,
                        obscureText: true,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20),
                        decoration: InputDecoration(
                            hintText: "Verify password",
                            hintStyle: TextStyle(
                                fontFamily: "Champagne & Limousines",
                                fontSize: 16,
                                color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ))),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _nextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:20.0),
      child: Expanded(
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
    context.bloc<LoginBloc>().add(NavigateToEulaEvent());
  }

  testSubmit(BuildContext context) {
    print('testSubmit');
    context.bloc<LoginBloc>().add(SubmitRegistrationEvent(_emailController.text,
        _firstNameController.text, _lastNameController.text));
  }
}
