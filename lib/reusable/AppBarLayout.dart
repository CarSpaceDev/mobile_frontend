import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';

AppBar arrowForwardAppBarWidget(BuildContext context, String appBarTitle, Function onPressed) {
  return AppBar(
    brightness: Brightness.dark,
    leading: GestureDetector(
        onTap: onPressed,
        child: Container(
          child: Icon(Icons.arrow_back_ios),
        )),
    title: Text(appBarTitle, style: TextStyle(color: Colors.white)),
    centerTitle: true,
    elevation: 0.0,
  );
}

AppBar mainAppBar(BuildContext context, String appBarTitle, Function onPressed) {
  return AppBar(
    backgroundColor: CSTheme().primary,
    brightness: Brightness.dark,
    title: Text(appBarTitle),
    centerTitle: true,
    leading: GestureDetector(
      onTap: () {},
      child: Container(child: Icon(Icons.menu)),
    ),
    actions: <Widget>[
      IconButton(
        color: Colors.white,
        onPressed: onPressed,
        icon: Icon(Icons.exit_to_app),
      ),
    ],
  );
}
