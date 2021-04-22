part of 'lot_geo_repo_bloc.dart';

abstract class LotGeoRepoEvent extends Equatable {
  const LotGeoRepoEvent();
}

class UpdateLotRepoCenter extends LotGeoRepoEvent {
  final CSPosition position;
  UpdateLotRepoCenter({@required this.position});
  @override
  List<Object> get props => [position];
}