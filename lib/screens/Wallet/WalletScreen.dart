import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/screens/Wallet/WalletBloc/wallet_bloc.dart';
import 'package:carspace/screens/Wallet/WalletInfoWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
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
      ),
      body: SafeArea(
        child: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Balance", style: TextStyle(fontSize: 24)),
            ),
            WalletInfoWidget(
              textColor: TextColor.Black,
              textType: TextType.H2,
              noRedirect: true,
            ),
            // if (loaded)
            //   Flexible(
            //       child: ListView.builder(
            //     itemCount: records.length,
            //     itemBuilder: (context, index) {
            //       return Container(
            //         color: Colors.black12,
            //         padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
            //         margin: EdgeInsets.symmetric(vertical: 8),
            //         child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text("From"),
            //               Text("${records[index].uid}"),
            //               Text("To"),
            //             ],
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text(records[index].fromName),
            //               Text(records[index].toName),
            //             ],
            //           ),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text("${records[index].ts.toString()}"),
            //               Text("${records[index].amount}"),
            //             ],
            //           ),
            //         ]),
            //       );
            //     },
            //   )),
            // if (!loaded)
            //   Padding(
            //     padding: const EdgeInsets.all(48.0),
            //     child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
            //   ),
            Padding(
              padding: EdgeInsets.all(36),
              child: TextButton(
                onPressed: () {
                  context.read<WalletBloc>().add(RefreshWallet(uid: locator<AuthService>().currentUser().uid));
                },
                child: Container(
                    padding: EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor,
                    child: Text("Refresh", style: TextStyle(fontSize: 24, color: Colors.white))),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
