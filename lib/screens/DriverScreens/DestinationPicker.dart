import 'package:carspace/CSMap/CSMap.dart';
import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/CSMap/bloc/geolocation_bloc.dart';
import 'package:carspace/CSMap/bloc/map_bloc.dart';
import 'package:carspace/repo/lotGeoRepo/lot_geo_repo_bloc.dart';
import 'package:carspace/reusable/CSText.dart';
import 'package:carspace/reusable/CSTile.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
          title: Text(widget.mode == BookingMode.Reservation ? "Reserve a Lot" : "Park at Destination"),
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
              onTap: (){
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

  getLocation() async {
    destination = await LocationSearchService.findLocation(context);
    if (destination != null) {
      CSPosition position =
          CSPosition.fromMap({"longitude": destination.location.longitude, "latitude": destination.location.latitude});
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
