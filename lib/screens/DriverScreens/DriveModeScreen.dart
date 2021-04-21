import 'dart:collection';

import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/blocs/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/Widgets/NavigationDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriveModeScreen extends StatefulWidget {
  @override
  _DriveModeScreenState createState() => _DriveModeScreenState();
}

class _DriveModeScreenState extends State<DriveModeScreen> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  LotGeoRepoBloc lotBloc;

  @override
  void dispose() {
    mapBloc.close();
    geoBloc.close();
    lotBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mapBloc == null) {
      mapBloc = new MapBloc();
    }
    if (geoBloc == null) {
      geoBloc = new GeolocationBloc();
    }
    if (lotBloc == null) {
      lotBloc = new LotGeoRepoBloc();
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (BuildContext context) => mapBloc),
        BlocProvider<GeolocationBloc>(create: (BuildContext context) => geoBloc),
        BlocProvider<LotGeoRepoBloc>(create: (BuildContext context) => lotBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GeolocationBloc, GeolocationState>(
            listener: (BuildContext context, state) {
              if (state is PositionUpdated) {
                // lotBloc.add(UpdateLotRepoCenter(position: state.position));
                var markers = HashSet<Marker>();
                markers.add(Marker(
                    markerId: MarkerId("DRIVER"),
                    icon: mapBloc.settings.driverIcon,
                    position: LatLng(state.position.latitude, state.position.longitude)));
                print(markers);
                mapBloc.add(UpdateMap(settings: mapBloc.settings.copyWith(markers: HashSet<Marker>())));
              }
            },
          ),
          BlocListener<LotGeoRepoBloc, LotGeoRepoState>(
            listener: (BuildContext context, state) {
              if (state is LotsUpdated) {
                var markers = HashSet<Marker>();
                for (Lot lot in state.lots) {
                  print(lot.toJson());
                  markers.add(Marker(
                      markerId: MarkerId(lot.lotId),
                      onTap: () {
                        // setState(() {
                        //   showLotCards = false;
                        // });
                        // if (userData != null) if (userData.currentReservation == null)
                        //   _showLotDialog(resultLotsInRadius[i]);
                      },
                      icon: mapBloc.settings.lotIcon,
                      position: LatLng(lot.coordinates[0], lot.coordinates[1])));
                }
                mapBloc.add(UpdateMap(settings: mapBloc.settings.copyWith(markers: HashSet<Marker>())));
              }
            },
          ),
        ],
        child: Scaffold(
          drawer: HomeNavigationDrawer(),
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            brightness: Brightness.dark,
            title: Text("Drive Mode"),
            centerTitle: true,
            leading: Builder(
              builder: (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(child: Icon(Icons.menu)),
              ),
            ),
            // actions: <Widget>[action],
            // bottom: PreferredSize(
            //   preferredSize: Size(MediaQuery.of(context).size.width, 52),
            //   child: LocationSearchWidget(
            //     // callback: locationSearchCallback,
            //     // controller: _searchController,
            //   ),
            // ),
          ),
          body: CSMap(mapBloc: context.bloc<MapBloc>(), geoBloc: context.bloc<GeolocationBloc>()),
        ),
      ),
    );
  }
}
