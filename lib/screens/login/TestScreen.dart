import 'package:carspace/model/GlobalData.dart';
import 'package:flutter/material.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:provider/provider.dart';
import 'login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<TestScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _verifyPasswordController;
  TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    _verifyPasswordController = TextEditingController(text: "");
    _displayNameController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
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
              Text(
                Provider.of<GlobalData>(context).heldEmail,
                style: TextStyle(
                    fontFamily: "Champagne & Limousines",
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 35.0),
              SizedBox(height: 22.0),
              _nextButton(),
              SizedBox(height: 5.0),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }

  Widget _nextButton() {
    return Container(
      margin: const EdgeInsets.fromLTRB(225.0, 0, 0, 0),
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () async {},
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


  navigateToEula(BuildContext context) {
    print('Navigate to Eula');
    context.watch<LoginBloc>().add(NavigateToEulaEvent());
  }
}
