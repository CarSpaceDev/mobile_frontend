import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/serviceLocator.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'lot_geo_repo_event.dart';
part 'lot_geo_repo_state.dart';

enum GeoSearchType { Pricing, Distance }

class LotGeoRepoBloc extends Bloc<LotGeoRepoEvent, LotGeoRepoState> {
  LotGeoRepoBloc() : super(LotGeoRepoInitial());
  @override
  Stream<LotGeoRepoState> mapEventToState(
    LotGeoRepoEvent event,
  ) async* {
    if (event is UpdateLotRepoCenter) {
      var result = await locator<ApiService>().getLotsInRadius(
          latitude: event.position.latitude,
          longitude: event.position.longitude,
          kmRadius: 10,
          type: GeoSearchType.Distance.index);
      if (result.statusCode == 200) {
        List<Lot> lots = [];
        for (var lot in result.body) {
          // print(lot);
          lots.add(Lot.fromJson(lot));
        }
        yield LotsUpdated(lots: lots);
      }
    }
  }
}
