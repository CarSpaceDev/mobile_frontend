part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();
}

class InitializeWallet extends WalletEvent {
  final String uid;
  InitializeWallet({this.uid});
  @override
  List<Object> get props => [uid];
}
class RefreshWallet extends WalletEvent {
  final String uid;
  RefreshWallet({this.uid});
  @override
  List<Object> get props => [uid];
}

class CashOut extends WalletEvent {
  final int amount;
  CashOut({this.amount});
  @override
  List<Object> get props => [amount];
}

class CashIn extends WalletEvent {
  final int amount;
  CashIn({this.amount});
  @override
  List<Object> get props => [amount];
}

class UpdateWallet extends WalletEvent {
  final Wallet wallet;
  UpdateWallet({this.wallet});
  @override
  List<Object> get props => [wallet];
}

class DisposeWallet extends WalletEvent {
  @override
  List<Object> get props => [];
}

