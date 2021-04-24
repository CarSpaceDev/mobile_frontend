import 'dart:collection';

import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/screens/DriverScreens/DestinationPicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

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
              // driver = Marker(
              //     markerId: MarkerId("DRIVER"),
              //     icon: mapBloc.settings.driverIcon,
              //     position: LatLng(geoBloc.lastKnownPosition.latitude, geoBloc.lastKnownPosition.longitude));
              // if (state is GeolocatorReady) {
              //   geoBloc.add(StartGeolocation());
              //   // if (mapBloc.state is MapSettingsReady) {
              //   //   print("FIRST ADD OF DRIVER MARKER");
              //   //   var markers = HashSet<Marker>();
              //   //   markers.add(driver);
              //   //   mapBloc.add(UpdateMap(settings: mapBloc.settings.copyWith(markers: markers)));
              //   // }
              // }
              if (state is PositionUpdated) {
                if (mapBloc.state is MapSettingsReady) {
                  // driver = Marker(
                  //     markerId: MarkerId("DRIVER"),
                  //     icon: mapBloc.settings.driverIcon,
                  //     position: LatLng(state.position.latitude, state.position.longitude));
                  lotBloc.add(UpdateLotRepoCenter(position: state.position));
                } else
                  print("MAP IS NOT YET READY");
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
                // markers.add(driver);
                for (Lot lot in state.lots) {
                  markers.add(Marker(
                      markerId: MarkerId(lot.lotId),
                      onTap: null,
                      icon: mapBloc.settings.lotIcon,
                      position: LatLng(lot.coordinates.latitude, lot.coordinates.longitude)));
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
            actions: [
              BlocBuilder<MapBloc, MapState>(builder: (BuildContext context, state) {
                if (state is MapSettingsReady) {
                  return Row(
                    children: [
                      Icon(state.settings.showPOI ? CupertinoIcons.map_pin : CupertinoIcons.map_pin_slash),
                      Switch(
                        value: state.settings.showPOI,
                        onChanged: (bool v) {
                          mapBloc.add(UpdateMap(settings: state.settings.copyWith(showPOI: v)));
                        },
                        inactiveTrackColor: csStyle.csWhite,
                        activeTrackColor: csStyle.csGrey,
                        activeColor: csStyle.csWhite,
                      ),
                    ],
                  );
                } else
                  return Container();
              })
            ],
            bottom: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, 52),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 52,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CSTile(
                      onTap: () {
                        showRadiusOptions(context, lotBloc);
                      },
                      expanded: true,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      margin: EdgeInsets.all(8),
                      showBorder: true,
                      color: TileColor.White,
                      child: CSText("Searching for lots within ${lotBloc.searchRadius} km"),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            child: Column(children: [
              Flexible(
                child: BlocBuilder<MapBloc, MapState>(builder: (BuildContext context, state) {
                  if (state is MapInitial) {
                    print("Firing Initialize MapSettings Event");
                    context.bloc<MapBloc>().add(InitializeMapSettings());
                  }
                  if (state is MapSettingsReady) {
                    return CSMap();
                  } else
                    return Container();
                }),
              ),
              CSTile(
                onTap: () {
                  //BookingMode.Booking.index
                },
                color: lotsAvailable > 0 ? TileColor.Secondary : TileColor.DarkGrey,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: lotsAvailable > 0 ? Colors.white70 : Colors.white,
                  child: CSText(
                    lotsAvailable > 0 ? "BOOK NOW" : "NO LOTS AVAILABLE",
                    textColor: lotsAvailable > 0 ? TextColor.White : TextColor.Primary,
                    textType: TextType.Button,
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  showRadiusOptions(BuildContext context, LotGeoRepoBloc bloc) {
    Map<String, double> distance = {
      "Walking Distance: 500m": 0.5,
      "Near: 1km": 1,
      "Short drive: 3km": 3,
      "Far: 5km": 5,
      "Very, very far: 10km": 10
    };
    Map<double, String> distanceToString = {
      0.5: "Walking Distance: 500m",
      1: "Near: 1km",
      3: "Short drive: 3km",
      5: "Far: 5km",
      10: "Very, very far: 10km"
    };

    showMaterialRadioPicker(
        context: context,
        title: "Search Radius",
        confirmText: "OK",
        cancelText: "CANCEL",
        items: distance.keys.toList(),
        selectedItem: distanceToString[bloc.searchRadius],
        onChanged: (String v) {
          bloc.add(UpdateSearchTerms(searchRadius: distance[v]));
          setState(() {});
        });
  }
}
