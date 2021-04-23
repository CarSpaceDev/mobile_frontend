import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/Home/LotFound.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../serviceLocator.dart';

enum BookingMode { Booking, Reservation }

class DestinationPicker extends StatefulWidget {
  final BookingMode mode;
  DestinationPicker({this.mode = BookingMode.Reservation});
  @override
  _DestinationPickerState createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  MapBloc mapBloc;
  GeolocationBloc geoBloc;
  bool enablePan;
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
    if (context.bloc<GeolocationBloc>() == null) {
      geoBloc = new GeolocationBloc();
    } else
      geoBloc = context.bloc<GeolocationBloc>();
    return MultiBlocProvider(
      providers: [
        BlocProvider<MapBloc>(create: (BuildContext context) => mapBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          brightness: Brightness.dark,
          title: Text(widget.mode == BookingMode.Reservation
              ? "Reserve a Lot"
              : "Park at Destination"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          child: Column(children: [
            if (destination == null)
              CSTile(
                onTap: () async {
                  await getLocation();
                },
                color: TileColor.White,
                shadow: true,
                margin: EdgeInsets.zero,
                child: CSText(
                  "Select Destination",
                  textColor: TextColor.Primary,
                  textType: TextType.Button,
                ),
              ),
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
                body: Column(children: [
                  CSText(
                    destination.locationDetails.toString(),
                    textColor: TextColor.Primary,
                    textType: TextType.Body,
                  ),
                  CSText(
                    "Tap to select new location, drag pin to refine position",
                    textColor: TextColor.Primary,
                    textType: TextType.Body,
                    padding: EdgeInsets.only(top: 16),
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
                callToAction();
                //sends api data
                //locator<AuthService>().currentUser().uid
                //widget.mode.index
              },
              color: TileColor.Secondary,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CSText(
                "Reserve Now",
                textColor: TextColor.White,
                textType: TextType.Button,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  callToAction() async {
    if (destination == null) {
      return print('Test');
    }
    var userId = locator<AuthService>().currentUser().uid;
    var body = ({
      "lat": destination.location.latitude,
      "lng": destination.location.longitude,
      "radiusInKm": .5,
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: new SizedBox(
                  height: 500,
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
                destination.location = newPos;
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
