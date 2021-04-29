import 'dart:collection';

import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotRepo/lot_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LoadingFullScreenWidget.dart';
import 'package:carspace/reusable/NavigationDrawer.dart';
import 'package:carspace/screens/Lots/LotTileWidget.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LotsScreen extends StatefulWidget {
  @override
  _LotsScreenState createState() => _LotsScreenState();
}

class _LotsScreenState extends State<LotsScreen> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  PageController controller;
  List<Lot> lots = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller = PageController();
    mapBloc.close();
    geoBloc.add(CloseGeolocationStream());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mapBloc == null) {
      mapBloc = new MapBloc();
    }
    if (geoBloc == null) geoBloc = context.bloc<GeolocationBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (BuildContext context) => mapBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          title: Text('Your Lots'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                context.bloc<LotRepoBloc>().add(InitializeLotRepo(uid: locator<AuthService>().currentUser().uid));
              },
            )
          ],
        ),
        body: BackgroundImage(
          padding: EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              BlocBuilder<LotRepoBloc, LotRepoState>(builder: (BuildContext context, state) {
                if (state is LotsReady && state.lots.isNotEmpty) {
                  return Container(
                    height: 160,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<MapBloc, MapState>(builder: (BuildContext context, state) {
                      if (state is MapInitial) {
                        print("Firing Initialize MapSettings Event");
                        context.bloc<MapBloc>().add(InitializeMapSettings());
                      }
                      if (state is MapSettingsReady) {
                        HashSet<Marker> markers = HashSet<Marker>();
                        for (var i = 0; i < lots.length; i++) {
                          markers.add(Marker(
                              markerId: MarkerId(lots[i].lotId),
                              onTap: () {},
                              icon: lots[i].availableSlots != 0
                                  ? lots[i].status == LotStatus.Active
                                      ? mapBloc.settings.lotIcon
                                      : mapBloc.settings.lotIconInactive
                                  : mapBloc.settings.lotIconInactive,
                              position: lots[i].coordinates.toLatLng()));
                        }
                        mapBloc.add(
                            UpdateMap(settings: mapBloc.settings.copyWith(markers: markers, scrollEnabled: false)));
                      }
                      return CSMap();
                    }),
                  );
                }
                return Container();
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: BlocBuilder<LotRepoBloc, LotRepoState>(
                    builder: (BuildContext context, state) {
                      if (state is LotsReady) {
                        lots = state.lots;
                        if (mapBloc.state is MapSettingsReady) {
                          HashSet<Marker> markers = HashSet<Marker>();
                          for (var i = 0; i < lots.length; i++) {
                            markers.add(Marker(
                                anchor: Offset(0, 0),
                                markerId: MarkerId(lots[i].lotId),
                                onTap: () {},
                                icon: lots[i].status == LotStatus.Active
                                    ? mapBloc.settings.lotIcon
                                    : mapBloc.settings.lotIconInactive,
                                position: lots[i].coordinates.toLatLng()));
                          }
                          mapBloc.add(
                              UpdateMap(settings: mapBloc.settings.copyWith(markers: markers, scrollEnabled: false)));
                        }
                        if (state.lots.isEmpty) {
                          return Center(
                            child: CSText(
                              "No lots at the moment, please head over to the partner dashboard website",
                              textType: TextType.Button,
                              textColor: TextColor.Black,
                            ),
                          );
                        }
                        return PageView.builder(
                          controller: controller,
                          itemCount: state.lots.length,
                          onPageChanged: (i) {
                            geoBloc.add(UpdatePositionManual(position: state.lots[i].coordinates));
                          },
                          itemBuilder: (BuildContext context, index) {
                            return LotTileWidget(lot: state.lots[index]);
                          },
                        );
                      } else
                        return LoadingFullScreenWidget();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
