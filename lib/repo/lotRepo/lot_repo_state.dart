part of 'lot_repo_bloc.dart';

abstract class LotRepoState extends Equatable {
  const LotRepoState();
}

class LotRepoInitial extends LotRepoState {
  @override
  List<Object> get props => [];
}

class LotsReady extends LotRepoState {
  final List<Lot> lots;
  LotsReady({this.lots});
  @override
  List<Object> get props => [lots];
}