import 'dart:collection';

import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/blocs/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
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
  Marker driver;
  int lotsAvailable = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    mapBloc.close();
    geoBloc.add(CloseGeolocationStream());
    lotBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mapBloc == null) {
      mapBloc = new MapBloc();
    }
    if (context.bloc<GeolocationBloc>() == null) {
      geoBloc = new GeolocationBloc();
    } else
      geoBloc = context.bloc<GeolocationBloc>();
    if (lotBloc == null) {
      lotBloc = new LotGeoRepoBloc();
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (BuildContext context) => mapBloc),
        BlocProvider<LotGeoRepoBloc>(create: (BuildContext context) => lotBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<GeolocationBloc, GeolocationState>(
            listener: (BuildContext context, state) {
              print("POSITION UPDATED");
              if (state is PositionUpdated) {
                driver = Marker(
                    markerId: MarkerId("DRIVER"),
                    icon: mapBloc.settings.driverIcon,
                    position: LatLng(state.position.latitude, state.position.longitude));
                lotBloc.add(UpdateLotRepoCenter(position: state.position));
              }
            },
          ),
          BlocListener<LotGeoRepoBloc, LotGeoRepoState>(
            listener: (BuildContext context, state) {
              if (state is LotsUpdated) {
                print("Updating Lot count");
                setState(() {
                  lotsAvailable = state.lots.length;
                });
                print(lotsAvailable);
                var markers = HashSet<Marker>();
                markers.add(driver);
                for (Lot lot in state.lots) {
                  markers.add(Marker(
                      markerId: MarkerId(lot.lotId),
                      onTap: null,
                      icon: mapBloc.settings.lotIcon,
                      position: LatLng(lot.coordinates[0], lot.coordinates[1])));
                }
                mapBloc.add(UpdateMap(settings: mapBloc.settings.copyWith(markers: markers)));
              }
            },
          ),
        ],
        child: Scaffold(
          // drawer: HomeNavigationDrawer(),
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            brightness: Brightness.dark,
            title: Text("Drive Mode"),
            centerTitle: true,
            // actions: <Widget>[action],
            // bottom: PreferredSize(
            //   preferredSize: Size(MediaQuery.of(context).size.width, 52),
            //   child: LocationSearchWidget(
            //     // callback: locationSearchCallback,
            //     // controller: _searchController,
            //   ),
            // ),
          ),
          body: Container(
            child: Column(children: [
              Flexible(
                child: CSMap(),
              ),
              CSTile(
                color: lotsAvailable > 0 ? TileColor.Primary : TileColor.Grey,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CSText(
                  lotsAvailable > 0 ? "BOOK NOW" : "NO LOTS AVAILABLE",
                  textColor: lotsAvailable > 0 ? TextColor.White : TextColor.Primary,
                  textType: TextType.Button,
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
