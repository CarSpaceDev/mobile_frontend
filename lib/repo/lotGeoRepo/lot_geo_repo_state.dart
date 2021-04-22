part of 'lot_geo_repo_bloc.dart';

abstract class LotGeoRepoState extends Equatable {
  const LotGeoRepoState();
}

class LotGeoRepoInitial extends LotGeoRepoState {
  @override
  List<Object> get props => [];
}

class LotsUpdated extends LotGeoRepoState {
  final List<Lot> lots;
  LotsUpdated({@required this.lots});
  @override
  List<Object> get props => [lots];
}
