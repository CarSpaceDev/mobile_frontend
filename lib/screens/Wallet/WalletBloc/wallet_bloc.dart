import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/model/Wallet.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../serviceLocator.dart';

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
      locator<ApiService>().getWalletStatus(uid: event.uid);
      wallet = FirebaseFirestore.instance.collection("wallets").doc(event.uid).snapshots().listen((result) {
        add(UpdateWallet(wallet: Wallet.fromDoc(result)));
      });
    }
    if(event is RefreshWallet){
      yield WalletInitial();
      await locator<ApiService>().getWalletStatus(uid: event.uid);
      yield WalletReady(wallet: walletData);
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
