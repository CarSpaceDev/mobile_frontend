import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';

import '../../serviceLocator.dart';

class WalletInfoWidget extends StatefulWidget {
  @override
  _WalletInfoWidgetState createState() => _WalletInfoWidgetState();
}

class _WalletInfoWidgetState extends State<WalletInfoWidget> {
  bool loaded = false;
  String balance = "";
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      shadow: true,
      onTap: () {
        locator<NavigationService>().pushNavigateTo(WalletRoute);
      },
      borderRadius: 8,
      color: TileColor.White,
      title: CSText(
        "WALLET BALANCE",
        textType: TextType.H5Bold,
      ),
      body: CSText(
        loaded ? "CSC $balance" : "GETTING BALANCE",
        padding: EdgeInsets.only(top: 4),
      ),
      trailing: Icon(CupertinoIcons.info),
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
