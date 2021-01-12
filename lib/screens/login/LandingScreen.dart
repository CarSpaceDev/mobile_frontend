import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../blocs/login/login_bloc.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  FocusNode fnEmail;
  FocusNode fnPass;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    fnEmail = FocusNode();
    fnPass = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        color: Color(0x00),
        child: FlatButton(
          onPressed: () {
            openBottomModal(context.bloc<LoginBloc>());
          },
          child: RichText(
            text: TextSpan(
              style: new TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2),
              children: <TextSpan>[
                TextSpan(text: 'Already have an account? '),
                TextSpan(text: 'Log In', style: new TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: LandingContent(),
    );
  }

  openBottomModal(LoginBloc loginBloc) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        backgroundColor: Colors.white,
        isDismissible: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.textMultiplier * 3.25),
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    focusNode: fnEmail,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    onEditingComplete: () {
                      fnPass.requestFocus();
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    focusNode: fnPass,
                    onEditingComplete: () {
                      fnPass.unfocus();
                      if (_emailController.text.isEmpty) {
                        showError(error: "Email cannot be empty");
                      } else if (_passwordController.text.isEmpty) {
                        showError(error: "Password cannot be empty");
                      } else if (!validateEmail(_emailController.text)) {
                        showError(error: 'Enter a valid email address');
                      } else {
                        Navigator.of(context).pop();
                        loginBloc.add(LogInEmailEvent(email: _emailController.text, password: _passwordController.text));
                      }
                    },
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton(
                      onPressed: () {
                        if (_emailController.text.isEmpty) {
                          showError(error: "Email cannot be empty");
                        } else if (_passwordController.text.isEmpty) {
                          showError(error: "Password cannot be empty");
                        } else if (!validateEmail(_emailController.text)) {
                          showError(error: 'Enter a valid email address');
                        } else {
                          Navigator.of(context).pop();
                          loginBloc.add(LogInEmailEvent(email: _emailController.text, password: _passwordController.text));
                        }
                      },
                      color: themeData.secondaryHeaderColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: SizeConfig.widthMultiplier * 50,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'Sign in',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FlatButton.icon(
                      color: themeData.secondaryHeaderColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        loginBloc.add(LoginGoogleEvent());
                      },
                      icon: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      label: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Login with Google',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  void showError({@required String error}) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.error,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [FlatButton(onPressed: Navigator.of(context).pop, child: Text("Close"))],
          );
        });
  }
}

class LandingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login_screen_assets/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Spacer(flex: 1),
                Flexible(
                  flex: 6,
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/logo/CarSpace.png',
                        width: SizeConfig.imageSizeMultiplier * 27.5,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2),
                          children: <TextSpan>[
                            TextSpan(
                              text: "CarSpace\n",
                              style: TextStyle(fontSize: SizeConfig.textMultiplier * 5, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "...because your parking matters",
                              style: TextStyle(fontSize: SizeConfig.textMultiplier * 2, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      Spacer(flex: 1),
                      FlatButton(
                        onPressed: () {
                          context.read<LoginBloc>().add(NavigateToEulaEvent());
                        },
                        color: themeData.secondaryHeaderColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          width: SizeConfig.widthMultiplier * 60,
                          height: SizeConfig.heightMultiplier * 6,
                          child: Center(
                            child: Text(
                              "Get Started",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2),
                            ),
                          ),
                        ),
                      ),
                      Spacer(flex: 1),
                      SizedBox.fromSize(
                        size: Size.fromHeight(kToolbarHeight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
