import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../serviceLocator.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("Wallet"),
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
        child: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CSText(
                "BALANCE",
                textType: TextType.H3Bold,
              ),
            ),
            WalletInfoWidget(
              textColor: TextColor.Black,
              textType: TextType.H2,
              noRedirect: true,
            ),
            BlocBuilder<WalletBloc, WalletState>(builder: (BuildContext context, WalletState state) {
              if (state is WalletReady) {
                return Flexible(
                  child: ListView.builder(
                    itemCount: state.wallet.transactions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.black12,
                        padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("From"),
                              Text("${state.wallet.transactions[index].transactionRef}"),
                              Text("To"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(state.wallet.transactions[index].fromName),
                              Text(state.wallet.transactions[index].toName),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${state.wallet.transactions[index].timestamp.toString()}"),
                              Text("${state.wallet.transactions[index].amount}"),
                            ],
                          ),
                        ]),
                      );
                    },
                  ),
                );
              }
              return Expanded(
                child: Center(
                  child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
                ),
              );
            }),
            CSTile(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Flexible(
                    child: CSTile(
                      padding: EdgeInsets.zero,
                      child: CSText("CASH IN"),
                    ),
                  ),
                  Flexible(
                    child: CSTile(
                      padding: EdgeInsets.zero,
                      child: CSText("CASH OUT"),
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
