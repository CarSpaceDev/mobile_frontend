part of 'lot_repo_bloc.dart';

abstract class LotRepoEvent extends Equatable {
  const LotRepoEvent();
}

class InitializeLotRepo extends LotRepoEvent {
  final String uid;
  InitializeLotRepo({this.uid});
  @override
  List<Object> get props => [uid];
}
class UpdateLotRepo extends LotRepoEvent {
  final List<Lot> lots;
  UpdateLotRepo({this.lots});
  @override
  List<Object> get props => [lots];
}
class DisposeLotRepo extends LotRepoEvent {
  DisposeLotRepo();
  @override
  List<Object> get props => [];
}


