import 'package:carspace/reusable/AppBarLayout.dart';
import 'package:carspace/screens/Login/code_confirmation_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhoneNumberRegistration extends StatefulWidget {
  @override
  _PhoneNumberRegistrationState createState() => _PhoneNumberRegistrationState();
}

class _PhoneNumberRegistrationState extends State<PhoneNumberRegistration> {
  TextEditingController numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: arrowForwardAppBarWidget(context, "CarSpace", () {}),
      backgroundColor: Theme.of(context).primaryColor,
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
                  child: Text('Sign up with you mobile number', style: TextStyle(color: Colors.white)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: numberController,
                        decoration: InputDecoration(
                            hintText: '+63 - ',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder:
                                new UnderlineInputBorder(borderSide: new BorderSide(color: Colors.white, width: 4.0)),
                            focusedBorder:
                                new UnderlineInputBorder(borderSide: new BorderSide(color: Colors.white, width: 4.0))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Center(
                        child: Text(
                          'We will be sending you a 6-digit confirmation code via SMS/email in order for you to register an account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _nextButton(context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 50.0),
    child: Container(
      child: FlatButton(
        height: 40,
        color: Color(0xFF534BAE), //534bae
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CodeConfirmation()));
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
