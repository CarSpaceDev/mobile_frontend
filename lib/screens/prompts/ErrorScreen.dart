import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ErrorScreen extends StatelessWidget {
  final String prompt;
  final bool showButtons;
  ErrorScreen({this.prompt, this.showButtons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        brightness: Brightness.dark,
        elevation: 0,
      ),
      bottomNavigationBar: showButtons == null || showButtons == false ? null : _nextButton(context),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 20 * SizeConfig.heightMultiplier,
                child: Image.asset('assets/logo/splash_icon.png'),
              ),
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          prompt != null ? prompt : "General Error",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FlatButton(
              height: 40,
              minWidth: MediaQuery.of(context).size.width * 0.35,
              color: Color(0xFF333333), //534bae
              onPressed: () {
                context.read<LoginBloc>().add(RestartLoginEvent());
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            FlatButton(
              height: 40,
              minWidth: MediaQuery.of(context).size.width * 0.35,
              color: Color(0xFF534BAE), //534bae
              onPressed: () {
                context.read<LoginBloc>().add(LoginStartEvent());
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
