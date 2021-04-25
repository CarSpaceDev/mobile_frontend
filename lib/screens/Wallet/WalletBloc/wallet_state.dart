part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();
}

class WalletInitial extends WalletState {
  @override
  List<Object> get props => [];
}

class WalletReady extends WalletState {
  final Wallet wallet;
  WalletReady({this.wallet});
  @override
  List<Object> get props => [wallet];
}
