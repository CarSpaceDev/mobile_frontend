import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'bloc.dart';

class LandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: themeData.primaryColor,
        extendBodyBehindAppBar: true,
        extendBody: true,
        bottomNavigationBar: BottomAppBar(
          color: Color(0x00),
          child: FlatButton(
            onPressed: () => buildShowModalBottomSheet(context),
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
        body: Builder(
          builder: (context) => LandingContent(),
        ));
  }

  Future buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        backgroundColor: Colors.white,
        isDismissible: true,
        context: context,
        builder: (BuildContext context) {
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
                    TextFormField(
                      initialValue: 'Username / Phone Number',
//                              autofocus: true,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      initialValue: 'Password',
                      textAlign: TextAlign.left,
                    ),
                    FlatButton(
                      onPressed: () {},
                      color: themeData.secondaryHeaderColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: SizeConfig.widthMultiplier * 50,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              'Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: SizeConfig.textMultiplier * 2.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FlatButton.icon(
                      color: themeData.secondaryHeaderColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () => {},
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        onPressed: () => {},
                        child: Text(
                          'New to CarSpace? Sign up',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: SizeConfig.textMultiplier * 2,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}

class LandingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/login_screen_assets/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            children: <Widget>[
              Spacer(flex: 1),
              Flexible(
                flex: 3,
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
              ),
              SizedBox.fromSize(
                size: Size.fromHeight(kToolbarHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  navigateToRegistration(BuildContext context) {
    print('Navigate to registration');
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    loginBloc.dispatch(NavRegisterEvent());
  }
}
