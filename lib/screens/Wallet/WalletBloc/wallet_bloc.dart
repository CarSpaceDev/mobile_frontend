import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Wallet.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  Wallet walletData;
  WalletBloc() : super(WalletInitial());
  StreamSubscription<DocumentSnapshot> wallet;
  @override
  Stream<WalletState> mapEventToState(
    WalletEvent event,
  ) async* {
    if (event is InitializeWallet) {
      await locator<ApiService>().getWalletStatus(uid: event.uid);
      wallet = FirebaseFirestore.instance.collection("wallets").doc(event.uid).snapshots().listen((result) {
        add(UpdateWallet(wallet: Wallet.fromDoc(result)));
      });
    }
    if (event is RefreshWallet) {
      yield WalletInitial();
      await locator<ApiService>().getWalletStatus(uid: event.uid);
      yield WalletReady(wallet: walletData);
    }
    if (event is CashIn) {
      print("Cashing In ${event.amount}");
      await locator<ApiService>().walletCashIn(
          data: {"uid": locator<AuthService>().currentUser().uid, "amount": event.amount, "transactionId": "CASH-IN"});
    }
    if (event is CashOut) {
      print("Cashing Out ${event.amount}");
      await locator<ApiService>().walletCashOut(
          data: {"uid": locator<AuthService>().currentUser().uid, "amount": event.amount, "transactionId": "CASH-OUT"});
    }

    if (event is UpdateWallet) {
      print("New update to wallet");
      walletData = event.wallet;
      yield WalletReady(wallet: event.wallet);
    }
    if (event is DisposeWallet) {
      print("WalletBlocCalledDispose");
      await wallet.cancel();
    }
  }
}
