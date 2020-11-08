import 'package:flutter/material.dart';
import 'package:carspace/model/GlobalData.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:provider/provider.dart';
import 'login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  @override
  _VehicleRegistrationScreenState createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
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
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            navigateToEula(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: Text(
          "Register Account",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/logo/CarSpace.png',
                      height: 115,
                      width: 115,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              Text(
                "let's create your account....",
                style: TextStyle(
                    fontFamily: "Champagne & Limousines",
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white),
              ),
              SizedBox(height: 35.0),
              TextField(
                  controller: _firstNameController,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "first name",
                      hintStyle: TextStyle(
                          fontFamily: "Champagne & Limousines",
                          fontSize: 20,
                          color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ))),
              TextField(
                  controller: _lastNameController,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "last name",
                      hintStyle: TextStyle(
                          fontFamily: "Champagne & Limousines",
                          fontSize: 20,
                          color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ))),
              TextField(
                  controller: _emailController,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "email address",
                      hintStyle: TextStyle(
                          fontFamily: "Champagne & Limousines",
                          fontSize: 20,
                          color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ))),
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "password",
                      hintStyle: TextStyle(
                          fontFamily: "Champagne & Limousines",
                          fontSize: 20,
                          color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ))),
              TextField(
                  controller: _verifyPasswordController,
                  obscureText: true,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                  decoration: InputDecoration(
                      hintText: "verify password",
                      hintStyle: TextStyle(
                          fontFamily: "Champagne & Limousines",
                          fontSize: 20,
                          color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ))),
              SizedBox(height: 22.0),
              _nextButton(),
              SizedBox(height: 5.0),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(225.0, 0, 0, 0),
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
            } else
              testSubmit(context);
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Next',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
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
    context.watch<LoginBloc>().add(NavigateToEulaEvent());
  }

  testSubmit(BuildContext context) {
    print('testSubmit');
    context.watch<LoginBloc>().add(SubmitRegistrationEvent(_emailController.text,
        _firstNameController.text, _lastNameController.text));
  }
}
