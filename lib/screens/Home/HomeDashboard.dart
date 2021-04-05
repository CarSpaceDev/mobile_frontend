import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeDashboard extends StatefulWidget {
  @override
  _HomeDashboardState createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: CSText("Dashboard", textType: TextType.H4, textColor: TextColor.White),
        actions: [IconButton(icon: Icon(CupertinoIcons.profile_circled), onPressed: () {})],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/login_screen_assets/bg.png"),
                  fit: BoxFit.cover,
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.dstATop),
                ),
              ),
            ),
            CSTile(
              margin: EdgeInsets.zero,
              color: TileColor.None,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CSTile(
                      child: CSText("PROFILE DATA"),
                    ),
                    CSTile(
                      child: CSText("WALLET DATA"),
                    ),
                    CSTile(
                      child: CSText("Current Selected Vehicle"),
                    ),
                    CSTile(
                      child: CSText("PARK NOW"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
