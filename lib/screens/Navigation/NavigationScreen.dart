import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      body: Container(child: Center(child: Text("Beta Functions"))),
      appBar: AppBar(
          backgroundColor: themeData.primaryColor,
          brightness: Brightness.dark,
          title: Text("Reservation"),
          centerTitle: true,
          leading: Builder(
              builder: (context) => InkWell(
                    onTap: () {},
                    child: Container(child: Icon(Icons.menu)),
                  )),
          actions: null,
          bottom: null),
    );
  }
}
