import 'dart:async';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/DevTools.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart';

import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;

String _mapStyle;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  Marker marker;
  Location location = Location();
  Set<Marker> _markers = HashSet<Marker>();
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  bool viewCentered;
  LatLng currentLocation;
  TextEditingController _searchController;
  ApiService _apiService = ApiService.create();
  bool workingMap = true;
  List<dynamic> lotsInRadius;
  bool lotsMarked = false;
  PickResult selectedPlace;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: "");
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    location.onLocationChanged.listen((location) async {
      devLog("LocationUpdate",
          "Updating location : [" + location.latitude.toString() + ',' + location.longitude.toString() + ']');
      if (lotsInRadius == null){
      var lots = await _apiService.findLotsFromRadius({
          "latitude": location.latitude,
          "longitude": location.longitude,
          "radius": 2000
        });
      print({
        "latitude": location.latitude,
        "longitude": location.longitude,
        "radius": 1500
      });
      print(lots.body);
      lotsInRadius = lots.body;
      }
      setState(() {
        currentLocation = LatLng(location.latitude, location.longitude);
        _markers.clear();
        _markers.add(
          Marker(
              markerId: MarkerId("Driver"),
              position: currentLocation,
              icon: _driverIcon,
              onTap: () {
                print("Driver");
              }),
        );
        for(int i = 0; i<lotsInRadius.length; i++){
          _markers.add(
            Marker(
                markerId: MarkerId("Lot Result $i"),
                position: LatLng(lotsInRadius[i]["location"]["coordinates"][1], lotsInRadius[i]["location"]["coordinates"][0]),
                icon: _lotIcon,
                onTap: () {
                  print("Lot Result $i: ${lotsInRadius[i]["address"].toString()}");
                }),
          );
        }
      });
      if (viewCentered == null) {
        devLog("ViewNotCentered", "view is not centered");
        mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 16.0,
            ),
          ),
        );
        setState(() {
          viewCentered = true;
        });
      }
    });
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      mapController.setMapStyle(_mapStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (workingMap)
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(1, 1),
                zoom: 16.0,
              ),
              markers: _markers,
            ),
            Positioned(
              bottom: SizeConfig.widthMultiplier * 5,
              left: SizeConfig.widthMultiplier * 5,
              child: FloatingActionButton(
                backgroundColor: themeData.secondaryHeaderColor,
                onPressed: () {
                  mapController?.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: currentLocation,
                        zoom: 16.0,
                      ),
                    ),
                  );
                },
                elevation: 3,
                child: Icon(Icons.center_focus_strong),
              ),
            ),
            Positioned(
              top: 16,
              child: PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 53),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: searchBar(context),
                ),
              ),
            ),
          ],
        ),
      );
    else
      return PlacePicker(
        apiKey: StringConstants.kGmapsApiKey,
        useCurrentLocation: true,
        //usePlaceDetailSearch: true,
        onPlacePicked: (result) {
          selectedPlace = result;
          Navigator.of(context).pop();
          setState(() {});
        },
        //forceSearchOnZoomChanged: true,
        //automaticallyImplyAppBarLeading: false,
        //autocompleteLanguage: "ko",
        //region: 'au',
        //selectInitialPosition: true,
        // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
        //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
        //   return isSearchBarFocused
        //       ? Container()
        //       : FloatingCard(
        //           bottomPosition: 0.0,    // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
        //           leftPosition: 0.0,
        //           rightPosition: 0.0,
        //           width: 500,
        //           borderRadius: BorderRadius.circular(12.0),
        //           child: state == SearchingState.Searching
        //               ? Center(child: CircularProgressIndicator())
        //               : RaisedButton(
        //                   child: Text("Pick Here"),
        //                   onPressed: () {
        //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
        //                     //            this will override default 'Select here' Button.
        //                     print("do something with [selectedPlace] data");
        //                     Navigator.of(context).pop();
        //                   },
        //                 ),
        //         );
        // },
        // pinBuilder: (context, state) {
        //   if (state == PinState.Idle) {
        //     return Icon(Icons.favorite_border);
        //   } else {
        //     return Icon(Icons.favorite);
        //   }
        // },
      );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      height: MediaQuery.of(context).size.height,
//      width: MediaQuery.of(context).size.width,
//      child: Stack(
//        children: [
//          GoogleMap(
//          onMapCreated: _onMapCreated,
//          initialCameraPosition: CameraPosition(
//            target: LatLng(1, 1),
//            zoom: 16.0,
//          ),
//          markers: _markers,
//        ), Positioned(
//            bottom: SizeConfig.widthMultiplier * 5,
//            left: SizeConfig.widthMultiplier * 5,
//            child: FloatingActionButton(
//              backgroundColor: themeData.secondaryHeaderColor,
//              onPressed: (){
//                mapController?.moveCamera(
//                CameraUpdate.newCameraPosition(
//                  CameraPosition(
//                    target: currentLocation,
//                    zoom: 16.0,
//                  ),
//                ),
//              );
//                },
//              elevation: 3,
//              child: Icon(Icons.center_focus_strong),
//            ),
//          ),
//          Positioned(
//            top: 16,
//            child: PreferredSize(
//              preferredSize: Size(MediaQuery.of(context).size.width, 53),
//              child: Container(
//                width: MediaQuery.of(context).size.width,
//                color: Colors.transparent,
//                child: searchBar(context),
//              ),
//            ),
//          ),
//        ],
//      ),
//    );
//  }

  void _setMarkerIcon() async {
    _lotIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
    _driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png');
  }

  searchBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Spacer(flex: 1),
        Container(
          width: MediaQuery.of(context).size.width * .75,
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontFamily: "Champagne & Limousines", color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              hintText: "Enter destination",
              hintStyle: TextStyle(fontFamily: "Champagne & Limousines", fontSize: 18, color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
        Spacer(flex: 1),
        Container(
          width: 50,
          height: 50,
          decoration: new BoxDecoration(
            color: themeData.secondaryHeaderColor,
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          child: Icon(Icons.search, color: Colors.white),
        ),
        Spacer(flex: 1),
      ],
    );
  }
}
