import 'package:carspace/constants/GlobalConstants.dart';
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
                      borderRadius: 8,
                      child: CSText("Current Reservation ETC"),
                    ),
                    CSSegmentedTile(
                      borderRadius: 8,
                      color: TileColor.White,
                      title: CSText("CURRENT BALANCE"),
                      body: CSText("WALLET DATA"),
                      trailing: Icon(CupertinoIcons.info),
                    ),
                    CSTile(
                      borderRadius: 8,
                      child: CSText("Current Selected Vehicle"),
                    ),
                    ParkNowWidget()
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

class ParkNowWidget extends StatefulWidget {
  @override
  _ParkNowWidgetState createState() => _ParkNowWidgetState();
}

class _ParkNowWidgetState extends State<ParkNowWidget> {
  PageController _pageController = new PageController();
  @override
  Widget build(BuildContext context) {
    return CSTile(
      padding: EdgeInsets.zero,
      shadow: true,
      showBorder: false,
      color: TileColor.None,
      child: Container(
        height: 160,
        decoration: BoxDecoration(color: csStyle.primary, borderRadius: BorderRadius.all(Radius.circular(8))),
        child: PageView(
          controller: _pageController,
          physics: new NeverScrollableScrollPhysics(),
          children: [
            //page 1
            InkWell(
              onTap: () {
                _pageController.animateToPage(1, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
              },
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CSText(
                        "PARK NOW",
                        textColor: TextColor.White,
                        textAlign: TextAlign.center,
                        textType: TextType.H2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //page 2
            Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.car_detailed,
                              color: csStyle.csWhite,
                            ),
                            CSText("DRIVE", textColor: TextColor.White)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        _pageController.jumpToPage(0);
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border(left: BorderSide(width: 1, color: csStyle.csWhite))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 0, width: 0),
                            Icon(
                              CupertinoIcons.time,
                              color: csStyle.csWhite,
                            ),
                            CSText("RESERVE", textColor: TextColor.White)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
