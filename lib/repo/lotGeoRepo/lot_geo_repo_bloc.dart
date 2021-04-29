import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'lot_geo_repo_event.dart';
part 'lot_geo_repo_state.dart';

enum GeoSearchType { Booking, Reservation }

class LotGeoRepoBloc extends Bloc<LotGeoRepoEvent, LotGeoRepoState> {
  GeoSearchType searchType = GeoSearchType.Booking;
  VehicleType vehicleSearchType = VehicleType.Motorcycle;
  double searchRadius = 0.5;
  CSPosition lastPosition;
  LotGeoRepoBloc() : super(LotGeoRepoInitial());
  @override
  Stream<LotGeoRepoState> mapEventToState(
    LotGeoRepoEvent event,
  ) async* {
    if (event is UpdateLotRepoCenter) {
      lastPosition = event.position;
      var result = await locator<ApiService>().getLotsInRadius({
        "lat": event.position.latitude,
        "lng": event.position.longitude,
        "radiusInKm": searchRadius,
        "type": searchType.index,
        "selectedVehicleType": vehicleSearchType.index
      });
      if (result.statusCode == 200) {
        List<Lot> lots = [];
        for (var lot in result.body) {
          // print(lot);
          lots.add(Lot.fromJson(lot));
        }
        yield LotsUpdated(lots: lots);
      } else
        print("API Error[LotGeoRepo]: ${result.statusCode}");
    }
    if (event is UpdateSearchTerms) {
      if (event.searchRadius != null) searchRadius = event.searchRadius;
      if (event.vehicleSearchType != null) vehicleSearchType = event.vehicleSearchType;
      if (event.searchType != null) searchType = event.searchType;
      if (lastPosition != null) {
        add(UpdateLotRepoCenter(position: lastPosition));
      }
    }
  }
}
