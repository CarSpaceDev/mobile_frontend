import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/widgets/NavigationDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../blocs/login/login_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  FocusNode fnEmail;
  FocusNode fnPass;
  GlobalKey formKey;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    formKey = GlobalKey();
    fnEmail = FocusNode();
    fnPass = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: BackgroundImage(
          padding: EdgeInsets.fromLTRB(32, 16, 32, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Center(child: LoginIcon()),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    child: Form(
                      key: formKey,
                      child:
                          Column(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(
                          controller: _emailController,
                          focusNode: fnEmail,
                          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                          onEditingComplete: () {
                            fnPass.requestFocus();
                          },
                          keyboardType: TextInputType.emailAddress,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              CupertinoIcons.mail,
                              color: Colors.white,
                            ),
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                          focusNode: fnPass,
                          keyboardType: TextInputType.visiblePassword,
                          enableSuggestions: false,
                          onEditingComplete: () {
                            fnPass.unfocus();
                            if (_emailController.text.isEmpty) {
                              showError(error: "Email cannot be empty");
                            } else if (_passwordController.text.isEmpty) {
                              showError(error: "Password cannot be empty");
                            } else if (!validateEmail(_emailController.text)) {
                              showError(error: 'Enter a valid email address');
                            } else {
                              context.read<LoginBloc>().add(
                                  LogInEmailEvent(email: _emailController.text, password: _passwordController.text));
                            }
                          },
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                CupertinoIcons.lock,
                                color: Colors.white,
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(fontSize: 16, color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              CSTile(
                color: TileColor.Secondary,
                borderRadius: 30,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                padding: EdgeInsets.all(16),
                onTap: () {
                  if (_emailController.text.isEmpty) {
                    showError(error: "Email cannot be empty");
                  } else if (_passwordController.text.isEmpty) {
                    showError(error: "Password cannot be empty");
                  } else if (!validateEmail(_emailController.text)) {
                    showError(error: 'Enter a valid email address');
                  } else {
                    context
                        .read<LoginBloc>()
                        .add(LogInEmailEvent(email: _emailController.text, password: _passwordController.text));
                  }
                },
                child: CSText(
                  'Sign in',
                  textAlign: TextAlign.start,
                  textColor: TextColor.White,
                  textType: TextType.Button,
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom > 0.0 == false)
                CSTile(
                  color: TileColor.Secondary,
                  borderRadius: 30,
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  onTap: () {
                    context.read<LoginBloc>().add(LoginGoogleEvent());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      CSText(
                        'Login via Google',
                        textAlign: TextAlign.start,
                        textColor: TextColor.White,
                        textType: TextType.Button,
                        padding: EdgeInsets.only(left: 16, top: 4),
                      ),
                    ],
                  ),
                ),
              if (MediaQuery.of(context).viewInsets.bottom > 0.0 == false)
                CSTile(
                  onTap: () {},
                  color: TileColor.None,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                      children: <TextSpan>[
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(text: 'Sign Up', style: new TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
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

class LoginIcon extends StatelessWidget {
  const LoginIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CSTile(
          color: TileColor.None,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
          child: Image.asset(
            'assets/logo/CarSpace.png',
            width: MediaQuery.of(context).size.width * .3,
          ),
        ),
        CSTile(
          color: TileColor.None,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.fromLTRB(
            32,
            8,
            32,0,
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2),
              children: <TextSpan>[
                TextSpan(
                  text: "CarSpace\n",
                  style: TextStyle(
                      fontSize: SizeConfig.textMultiplier * 5, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "...because your parking matters",
                  style: TextStyle(fontSize: SizeConfig.textMultiplier * 2, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ],
    );
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
                              style: TextStyle(
                                  fontSize: SizeConfig.textMultiplier * 5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                        color: Theme.of(context).secondaryHeaderColor,
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
