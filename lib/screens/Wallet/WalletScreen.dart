import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0;
  List<PaymentRecord> records = [];
  bool loaded = false;

  @override
  void initState() {
    refresh();
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
            Text(
              "$balance",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 48),
            ),
            if (loaded)
              Flexible(
                  child: ListView.builder(
                itemCount: records.length,
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
                          Text("${records[index].uid}"),
                          Text("To"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(records[index].fromName),
                          Text(records[index].toName),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${records[index].ts.toString()}"),
                          Text("${records[index].amount}"),
                        ],
                      ),
                    ]),
                  );
                },
              )),
            if (!loaded)
              Padding(
                padding: const EdgeInsets.all(48.0),
                child: SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
              ),
            Padding(
              padding: EdgeInsets.all(36),
              child: TextButton(
                onPressed: () {
                  refresh();
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

  refresh() {
    loaded = false;
    locator<ApiService>().getWalletStatus(uid: locator<AuthService>().currentUser().uid).then((value) {
      List<PaymentRecord> result = [];
      List.from(value.body["previousTransactions"]).forEach((element) {
        result.add(PaymentRecord.fromJson(element));
      });
      setState(() {
        balance = double.parse("${value.body["balance"]}");
        records = result;
        loaded = true;
      });
    });
  }
}

class PaymentRecord {
  double amount;
  String fromId;
  String fromName;
  String toId;
  String toName;
  DateTime ts;
  String uid;
  String type;
  PaymentRecord();
  PaymentRecord.fromJson(dynamic json) {
    this.amount = double.parse('${json['amount']}');
    this.fromId = json['fromId'] as String;
    this.fromName = json['fromName'] as String;
    this.toId = json['toId'] as String;
    this.toName = json['toName'] as String;
    this.ts = DateTime.fromMillisecondsSinceEpoch(json["ts"]);
    this.uid = json["uid"] as String;
    this.type = json["type"] as String;
  }
}
