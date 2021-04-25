import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class WalletInfoWidget extends StatefulWidget {
  final TextColor textColor;
  WalletInfoWidget({this.textColor = TextColor.White});
  @override
  _WalletInfoWidgetState createState() => _WalletInfoWidgetState();
}

class _WalletInfoWidgetState extends State<WalletInfoWidget> {
  bool loaded = false;
  String balance = "";
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        locator<NavigationService>().pushNavigateTo(WalletRoute);
      },
      child: Center(
        child: CSText(
          loaded ? "CSC $balance" : ". . .",
          padding: EdgeInsets.only(top: 2, right: 10),
          textColor: widget.textColor,
          textType: TextType.Button,
        ),
      ),
    );
  }

  @override
  initState() {
    refresh();
    super.initState();
  }

  refresh() {
    locator<ApiService>().getWalletStatus(uid: locator<AuthService>().currentUser().uid).then((value) {
      if (value.statusCode == 200)
        setState(() {
          balance = double.parse("${value.body["balance"]}").toStringAsFixed(2);
          loaded = true;
        });
      else {
        setState(() {
          balance = "ERROR GETTING BALANCE";
          loaded = true;
        });
      }
    });
  }
}
