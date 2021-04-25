import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
class Wallet extends Equatable {
  final String uid;
  final double balance;
  final List<WalletTransaction> transactions;

  Wallet.fromDoc(DocumentSnapshot doc) :
      uid = doc.id,
  balance = doc.data()["balance"]!=null ? double.parse("${doc.data()['balance']}") : 0,
  transactions = List<dynamic>.from(doc.data()["transactions"]).map((transaction) => WalletTransaction.fromJson(transaction)).toList();


  @override
  List<Object> get props => [
    uid,
    balance,
    transactions
  ];
}



class WalletTransaction extends Equatable {
  final double amount;
  final String fromId;
  final String toId;
  final String fromName;
  final String toName;
  final DateTime timestamp;
  final String type;
  final String transactionRef;

  WalletTransaction.fromJson(Map<String,dynamic> json) :
      amount =  json["amount"]!=null ? double.parse("${json['amount']}") : null,
        fromId = json["fromId"] as String,
        toId = json["toId"] as String,
        fromName = json["fromName"] as String,
        toName = json["toName"] as String,
        timestamp = DateTime.fromMillisecondsSinceEpoch(json["ts"]),
        type = json["type"] as String,
        transactionRef = json["uid"]??null;


  @override
  List<Object> get props => [
    amount,
    fromId,
    toId,
    fromName,
    toName,
    timestamp,
    type,
    transactionRef
  ];

}
