import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bloc.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        color: Color(0x00),
        child: FlatButton(
          onPressed: () => showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              backgroundColor: Colors.white,
              isDismissible: true,
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                      height: SizeConfig.heightMultiplier * 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.textMultiplier * 3.25),
                          ),
                          TextField(
                              controller: _emailController,
                              style: TextStyle(
                                  fontFamily: "Champagne & Limousines",
                                  color: Colors.black,
                                  fontSize: 20),
                              decoration: InputDecoration(
                                  hintText: "enter email",
                                  hintStyle: TextStyle(
                                      fontFamily: "Champagne & Limousines",
                                      fontSize: 20,
                                      color: Colors.black),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ))),
                          TextField(
                              controller: _passwordController,
                              style: TextStyle(
                                  fontFamily: "Champagne & Limousines",
                                  color: Colors.black,
                                  fontSize: 20),
                              decoration: InputDecoration(
                                  hintText: "enter password",
                                  hintStyle: TextStyle(
                                      fontFamily: "Champagne & Limousines",
                                      fontSize: 20,
                                      color: Colors.black),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ))),
                          FlatButton(
                            onPressed: () {
                              loginBloc.dispatch(LogInEmailEvent(
                                  email: _emailController.text,
                                  password: _passwordController.text));
                            },
                            color: themeData.secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              width: SizeConfig.widthMultiplier * 50,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    'Login with Google',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            SizeConfig.textMultiplier * 2.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          FlatButton.icon(
                            color: themeData.secondaryHeaderColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onPressed: () {
                              loginBloc.dispatch(LoginGoogleEvent());
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
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.textMultiplier * 2.5),
                              ),
                            ],
                          )),
                    ),
                  ),
                );
              }),
          child: RichText(
            text: TextSpan(
              style: new TextStyle(
                  fontFamily: "Champagne & Limousines",
                  color: Colors.white,
                  fontSize: SizeConfig.textMultiplier * 2),
              children: <TextSpan>[
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                    text: 'Log In',
                    style: new TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: LandingContent(),
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
                          style: TextStyle(
                              fontFamily: 'Champagne & Limousines',
                              color: Colors.white,
                              fontSize: SizeConfig.textMultiplier * 2),
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
                    ],
                  ),
                ),
                Spacer(flex: 1),
                FlatButton(
                  onPressed: () {
                    navigateToRegistration(context);
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
                        style: TextStyle(
                            fontFamily: 'Champagne & Limousines',
                            color: Colors.white,
                            fontSize: SizeConfig.textMultiplier * 2),
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
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(flex: 1),
              FlatButton(
                onPressed: () {
                  navigateToRegistration(context);
                },
                color: themeData.secondaryHeaderColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: SizeConfig.widthMultiplier * 60,
                  height: SizeConfig.heightMultiplier * 6,
                  child: Center(
                    child: Text(
                      "Get Started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: SizeConfig.textMultiplier * 2.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: Size.fromHeight(kToolbarHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  navigateToRegistration(BuildContext context) {
    print('Navigate to registration');
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    loginBloc.dispatch(NavigateToRegisterEvent());
  }
}
