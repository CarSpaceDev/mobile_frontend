import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../serviceLocator.dart';

class WalletInfoWidget extends StatefulWidget {
  final TextColor textColor;
  final TextType textType;
  final bool noRedirect;
  WalletInfoWidget({this.textColor = TextColor.White, this.textType = TextType.Button, this.noRedirect = false});
  @override
  _WalletInfoWidgetState createState() => _WalletInfoWidgetState();
}

class _WalletInfoWidgetState extends State<WalletInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.noRedirect
          ? null
          : () {
              locator<NavigationService>().pushNavigateTo(WalletRoute);
            },
      child: Center(
        child: BlocBuilder<WalletBloc, WalletState>(builder: (BuildContext context, WalletState state) {
          if (state is WalletReady) {
            return CSText(
              "CSC ${state.wallet.balance.toStringAsFixed(2)}",
              padding: EdgeInsets.only(top: 2, right: 10),
              textColor: widget.textColor,
              textType: widget.textType,
            );
          } else
            return CSText(
              ". . .",
              padding: EdgeInsets.only(top: 2, right: 10),
              textColor: widget.textColor,
              textType: widget.textType,
            );
        }),
      ),
    );
  }
}
