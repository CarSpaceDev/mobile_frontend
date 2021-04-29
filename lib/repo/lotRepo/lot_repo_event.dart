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
class UpdateLotStatus extends LotRepoEvent {
  final Lot lot;
  final LotStatus status;
  UpdateLotStatus({this.lot, this.status});
  @override
  List<Object> get props => [lot, status];
}
class DisposeLotRepo extends LotRepoEvent {
  DisposeLotRepo();
  @override
  List<Object> get props => [];
}


