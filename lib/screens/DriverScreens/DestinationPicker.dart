import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/Home/LotFound.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';


enum ParkingType { Booking, Reservation, Both }

class DestinationPicker extends StatefulWidget {
  final ParkingType mode;
  DestinationPicker({this.mode = ParkingType.Reservation});
  @override
  _DestinationPickerState createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  LocationSearchResult destination;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
          backgroundColor: Theme.of(context).primaryColor,
          brightness: Brightness.dark,
          title: Text(widget.mode == ParkingType.Reservation
              ? "Reserve a Lot"
              : "Park at Destination"),
          centerTitle: true,
          actions: [
            BlocBuilder<MapBloc, MapState>(
                builder: (BuildContext context, state) {
              if (state is MapSettingsReady) {
                return Row(
                  children: [
                    Icon(state.settings.showPOI
                        ? CupertinoIcons.map_pin
                        : CupertinoIcons.map_pin_slash),
                    Switch(
                      value: state.settings.showPOI,
                      onChanged: (bool v) {
                        mapBloc.add(UpdateMap(
                            settings: state.settings.copyWith(showPOI: v)));
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
        ),
        body: Container(
          child: Column(children: [
            if (destination != null)
              CSSegmentedTile(
                onTap: () async {
                  await getLocation();
                },
                color: TileColor.White,
                shadow: true,
                margin: EdgeInsets.zero,
                // padding: EdgeInsets.symmetric(vertical: 32),
                title: CSText(
                  destination.locationDetails.name,
                  textColor: TextColor.Primary,
                  textType: TextType.Button,
                ),
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CSText(
                        destination.locationDetails.toString(),
                        textColor: TextColor.Primary,
                        textType: TextType.Body,
                        padding: EdgeInsets.only(top: 16, bottom: 8),
                      ),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.map_pin_ellipse,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          CSText(
                            "${(Geolocator.distanceBetween(
                                  destination.originalLocation.latitude,
                                  destination.originalLocation.longitude,
                                  destination.location.latitude,
                                  destination.location.longitude,
                                ) / 1000).toStringAsFixed(2)} km from landmark",
                            textColor: TextColor.Primary,
                            padding: EdgeInsets.only(top: 4, left: 8),
                          ),
                        ],
                      ),
                    ]),
              ),
            Flexible(
              child: BlocBuilder<MapBloc, MapState>(
                  builder: (BuildContext context, state) {
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
                destination != null ? callToAction() : getLocation();
              },
              color: destination != null
                  ? TileColor.Secondary
                  : TileColor.DarkGrey,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor:
                    destination != null ? Colors.white70 : Colors.white,
                child: CSText(
                  destination != null ? "RESERVE NOW" : "Select A Destination",
                  textColor: TextColor.White,
                  textType: TextType.H3Bold,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  callToAction() async {
    var userId = locator<AuthService>().currentUser().uid;
    var body = ({
      "lat": destination.location.latitude,
      "lng": destination.location.longitude,
      "radiusInKm": 0.5,
      "type": widget.mode.index,
      "userId": userId
    });

    var result = await locator<ApiService>().getLotFromAlgo(body);

    if (result.body['returnPayLoad'] == null) {
      return showMessage(result.body['message']);
    } else {
      Lot lot = Lot.fromJson(result.body["returnPayLoad"][0]);
      return showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => Dialog(
                insetPadding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .1,
                    horizontal: 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: new SizedBox(
                  height: 700,
                  width: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: LotFound(lot, userId, widget.mode.index),
                    ),
                  ),
                ),
              ));
    }
  }

  showMessage(String v) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                    Text(
                      "$v",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Close'))
            ],
          );
        });
  }

  getLocation() async {
    destination = await LocationSearchService.findLocation(context);
    if (destination != null) {
      CSPosition position = CSPosition.fromMap({
        "longitude": destination.location.longitude,
        "latitude": destination.location.latitude
      });
      mapBloc.add(
        ShowDestinationMarker(
          marker: Marker(
              markerId: MarkerId("DESTINATION"),
              draggable: true,
              position: LatLng(position.latitude, position.longitude),
              onDragEnd: (LatLng newPos) {
                print("NewPosition: ${newPos.toJson()}");
                setState(() {
                  destination.location = CSPosition.fromMap({
                    "latitude": newPos.latitude,
                    "longitude": newPos.longitude
                  });
                });
              }),
        ),
      );
      geoBloc.add(UpdatePositionManual(position: position));
    }
    setState(() {});
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
