import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Wallet.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/PopupNotifications.dart';
import 'package:carspace/screens/Wallet/CashInScreen.dart';
import 'package:carspace/screens/Wallet/CashOutScreen.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../services/navigation.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  ScrollController controller;
  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.dark,
        title: CSText(
          "My Wallet",
          textType: TextType.H4,
          textColor: TextColor.White,
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                CupertinoIcons.refresh_thick,
                color: csStyle.csWhite,
              ),
              onPressed: () {
                context.read<WalletBloc>().add(RefreshWallet(uid: locator<AuthService>().currentUser().uid));
              })
        ],
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
              child: WalletInfoWidget(
                textColor: TextColor.Primary,
                textType: TextType.H2,
                noRedirect: true,
              ),
            ),
          ),
          Column(
            children: [
              CSTile(
                margin: EdgeInsets.only(top: 8, bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 16),
                color: TileColor.Grey,
                child: Row(
                  children: [
                    Flexible(
                      child: CSTile(
                        onTap: () {
                          locator<NavigationService>().pushNavigateToWidget(
                            getPageRoute(
                              CashInScreen(),
                              RouteSettings(name: "CASH-IN"),
                            ),
                          );
                        },
                        shadow: true,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        borderRadius: 15,
                        margin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.creditcard_fill,
                              color: Theme.of(context).primaryColor,
                            ),
                            CSText(
                              "CASH IN",
                              textColor: TextColor.Primary,
                              textType: TextType.Button,
                              padding: EdgeInsets.only(left: 4, top: 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 16,
                    ),
                    Flexible(
                      child: CSTile(
                        onTap: () {
                          locator<NavigationService>().pushNavigateToWidget(
                            getPageRoute(
                              CashOutScreen(),
                              RouteSettings(name: "CASHOUT"),
                            ),
                          );
                        },
                        shadow: true,
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        borderRadius: 15,
                        margin: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.creditcard,
                              color: Theme.of(context).primaryColor,
                            ),
                            CSText(
                              "CASH OUT",
                              textColor: TextColor.Primary,
                              textType: TextType.Button,
                              padding: EdgeInsets.only(left: 4, top: 2),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              CSTile(
                margin: EdgeInsets.zero,
                color: TileColor.Grey,
                child: CSText(
                  "PREVIOUS TRANSACTIONS",
                  textColor: TextColor.Primary,
                  textType: TextType.Button,
                  padding: EdgeInsets.only(left: 4, top: 2),
                ),
              )
            ],
          ),
          BlocBuilder<WalletBloc, WalletState>(builder: (BuildContext context, WalletState state) {
            if (state is WalletReady) {
              return Flexible(
                child: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  color: csStyle.csGreyBackground,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: controller,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: state.wallet.transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionListTile(
                          transaction: state.wallet.transactions[index],
                          onTap: () {
                            PopupNotifications.showNotificationDialog(
                              context,
                              barrierDismissible: true,
                              child: TransactionRecordDetailWidget(transaction: state.wallet.transactions[index]),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }
            return Expanded(
              child: Center(
                child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

class TransactionRecordDetailWidget extends StatelessWidget {
  final WalletTransaction transaction;
  TransactionRecordDetailWidget({@required this.transaction});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      padding: EdgeInsets.all(16),
      title: CSText(
        transaction.fromId != locator<AuthService>().currentUser().uid ? transaction.fromName : "YOU",
        textType: TextType.Button,
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CSText(
          "To: ${transaction.toName}",
          padding: EdgeInsets.only(top: 4),
        ),
        CSText(
          "Ref: ${transaction.transactionRef}",
          padding: EdgeInsets.only(top: 4),
        ),
        CSText(
          "${formatDate(transaction.timestamp, [MM, " ", dd, ", ", yyyy, " ", HH, ":", nn])}",
          padding: EdgeInsets.only(top: 4),
        ),
      ]),
      trailing: CSTile(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: EdgeInsets.zero,
        color: TileColor.Grey,
        shadow: true,
        borderRadius: 5,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60, maxWidth: 60),
          child: CSText(
            "${transaction.amount}",
            textColor: TextColor.White,
            textType: TextType.H5Bold,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  final Function onTap;
  final WalletTransaction transaction;
  TransactionListTile({@required this.transaction, this.onTap});
  @override
  Widget build(BuildContext context) {
    return CSSegmentedTile(
      onTap: onTap,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: TileColor.Grey,
      shadow: true,
      borderRadius: 20,
      title: CSText(
        transaction.fromId != locator<AuthService>().currentUser().uid
            ? transaction.fromName
            : "${transaction.fromName} (you)",
        textColor: TextColor.Primary,
        textType: TextType.Button,
      ),
      body: CSText(
        "${formatDate(transaction.timestamp, [MM, " ", dd, ", ", yyyy, " ", HH, ":", nn])}",
        textColor: TextColor.Primary,
        padding: EdgeInsets.only(top: 4),
      ),
      trailing: CSTile(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.zero,
        color: transaction.amount.isNegative ? TileColor.Red : TileColor.Green,
        shadow: true,
        borderRadius: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 60, maxWidth: 60),
          child: CSText(
            transaction.amount.isNegative ? "(${transaction.amount})".replaceAll("-", "") : "${transaction.amount}",
            textColor: TextColor.White,
            textType: TextType.H5Bold,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
