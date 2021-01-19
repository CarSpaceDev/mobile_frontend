import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneCodeConfirmScreen extends StatefulWidget {
  @override
  _PhoneCodeConfirmScreenState createState() => _PhoneCodeConfirmScreenState();
}

class _PhoneCodeConfirmScreenState extends State<PhoneCodeConfirmScreen> {
  TextEditingController numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: arrowForwardAppBarWidget(context, "CarSpace", () {}),
      backgroundColor: themeData.primaryColor,
      bottomNavigationBar: _nextButton(context),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: (size.height / 100) * 20, child: Image.asset('assets/images/mobile.png')),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text('Please enter your confirmation code below', style: TextStyle(color: Colors.white)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 24),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.phone,
                        controller: numberController,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: '* * * * * *',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white, width: 4.0),
                          ),
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white, width: 4.0),
                          ),
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       vertical: 10, horizontal: 50.0),
                    //   child: Center(
                    //     child: RichText(
                    //       text: TextSpan(
                    //           text: 'Resend my code in',
                    //           children: <TextSpan>[
                    //             TextSpan(
                    //                 text: ' .30s',
                    //                 style: TextStyle(
                    //                     color: Colors.yellowAccent,
                    //                     fontWeight: FontWeight.bold)),
                    //           ]),
                    //     ),
                    //   ),
                    // )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
      child: Container(
        child: FlatButton(
          height: 40,
          color: Color(0xFF534BAE), //534bae
          onPressed: () {
            context.read<LoginBloc>().add(ConfirmPhoneCodeEvent(code: numberController.text));
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
}
