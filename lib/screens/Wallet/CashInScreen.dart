import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/Popup.dart';
import 'package:carspace/screens/Home/PopupNotifications.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../serviceLocator.dart';
import 'WalletInfoWidget.dart';

class CashInScreen extends StatefulWidget {
  @override
  _CashInScreenState createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  String amount = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.dark,
        title: CSText(
          "Cash In",
          textType: TextType.H4,
          textColor: TextColor.White,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: CSTile(
              margin: EdgeInsets.fromLTRB(16, 8, 16, 24),
              borderRadius: 15,
              color: TileColor.White,
              shadow: true,
              child: CSTile(
                margin: EdgeInsets.zero,
                child: CSText("${amount.isEmpty ? "0" : amount}",
                    textType: TextType.H2, textColor: TextColor.Primary),
              ),
            ),
          ),
          buildKeyPad(),
          CSTile(
            onTap: () {
              if (amount.isNotEmpty && int.parse(amount) >= 100) {
                PopUp.showOption(
                    context: context,
                    title: "Please Confirm",
                    body: "Cash in $amount?",
                    onAccept: () {
                      context.bloc<WalletBloc>().add(CashIn(amount: int.parse(amount)));
                      Navigator.of(context).pop();
                      PopUp.showInfo(
                          context: context,
                          title: "Processing",
                          body:
                          "Your wallet will be updated. Please press the refresh icon if it is not automatically updated",
                          onAcknowledge: () {
                            locator<NavigationService>().navigatorKey.currentContext.bloc<WalletBloc>().add(RefreshWallet());
                          });
                    });
              } else
                PopupNotifications.showNotificationDialog(context,
                    barrierDismissible: true,
                    child: CSTile(
                      child: CSText(
                          "You need to cash in at least CSC 100"),
                    ));
            },
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(vertical: 32),
            color: amount.isNotEmpty && int.parse(amount) >= 100
                ? TileColor.Primary
                : TileColor.DarkGrey,
            child: CSText(
              amount.isNotEmpty && int.parse(amount) >= 00
                  ? "CASH IN"
                  : "INVALID AMOUNT (MIN 100.00)",
              textColor: TextColor.White,
              textType: TextType.Button,
            ),
          )
        ])
      ),
    );
  }

  Expanded buildKeyPad() {
    return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CSTile(
                padding: EdgeInsets.symmetric(horizontal: 32),
                color: TileColor.None,
                child: Column(
                  children: [
                    Row(
                      children: [
                        KeyPadButton(
                          child: CSText("1", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(1);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("2", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(2);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("3", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(3);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        KeyPadButton(
                          child: CSText("4", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(4);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("5", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(5);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("6", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(6);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        KeyPadButton(
                          child: CSText("7", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(7);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("8", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(8);
                          },
                        ),
                        KeyPadButton(
                          child: CSText("9", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(9);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(child: Container()),
                        KeyPadButton(
                          child: CSText("0", textColor: TextColor.White, textType: TextType.H3Bold),
                          onTap: () {
                            add(0);
                          },
                        ),
                        KeyPadButton(
                            onTap: () {
                              subtract();
                            },
                            child: Icon(
                              CupertinoIcons.arrow_left,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
  }

  add(int value) {
    setState(() {
      amount += "$value";
    });
  }

  subtract() {
    if (amount.length > 1)
      setState(() {
        amount = amount.substring(0, amount.length - 1);
      });
    else
      setState(() {
        amount = '';
      });
  }
}

class KeyPadButton extends StatelessWidget {
  final Function onTap;
  final Widget child;
  final int flex;
  KeyPadButton({@required this.child, this.onTap, this.flex = 1});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: flex,
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 16 / 12,
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Center(
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
