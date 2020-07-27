import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/screens/ReservationScreen/ReservationScreen.dart';
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
  BitmapDescriptor _markerIcon;
  bool viewCentered;
  LatLng currentLocation;
  TextEditingController _searchController;
  bool options = false;
  bool suggestedLocation = false;
  bool workingMap = true;

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
      devLog(
          "LocationUpdate",
          "Updating location : [" +
              location.latitude.toString() +
              ',' +
              location.longitude.toString() +
              ']');
      setState(() {
        currentLocation = LatLng(location.latitude, location.longitude);
        _markers.clear();
        _markers.add(
          Marker(
              markerId: MarkerId("0"),
              position: currentLocation,
              icon: _markerIcon,
              onTap: () {
                print("SomeCallback");
              }),
        );
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      mapController.setMapStyle(_mapStyle);
    });
  }

  setOptions() {
    setState(() {
      this.options = true;
      this.suggestedLocation = false;
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
                  setOptions();
                },
                elevation: 3,
                child: Icon(Icons.more_horiz),
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
            options
                ? Positioned(
                    bottom: SizeConfig.widthMultiplier * 5,
                    left: SizeConfig.widthMultiplier * 5,
                    child: Row(
                      children: <Widget>[
                        FloatingActionButton(
                          backgroundColor: themeData.secondaryHeaderColor,
                          elevation: 3,
                          child: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            setState(() {
                              this.options = false;
                            });
                            print(this.options);
                          },
                        ),
                        SizedBox(width: 5),
                        FloatingActionButton(
                          backgroundColor: themeData.secondaryHeaderColor,
                          elevation: 3,
                          child: Icon(Icons.center_focus_strong),
                          onPressed: () {
                            setState(() {
                              this.options = false;
                            });
                            mapController
                                ?.moveCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: currentLocation,
                                zoom: 16.0,
                              ),
                            ));
                          },
                        ),
                        SizedBox(width: 5),
                        FloatingActionButton(
                          backgroundColor: themeData.secondaryHeaderColor,
                          elevation: 3,
                          child: Icon(Icons.location_on),
                          onPressed: () {
                            setState(() {
                              this.options = false;
                              this.suggestedLocation = true;
                            });
                          },
                        )
                      ],
                    ),
                  )
                : Container(),
            suggestedLocation ? Positioned(
                bottom: SizeConfig.widthMultiplier * 22,
                left: SizeConfig.widthMultiplier * 10,
                right: SizeConfig.widthMultiplier * 10,
              child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                  },
                  child: SuggestedLocationCard()),
            ):Container()
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
    _markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)),
        'assets/launcher_icon/pushpin.png');
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
            style: TextStyle(
                fontFamily: "Champagne & Limousines",
                color: Colors.black,
                fontSize: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter destination",
              hintStyle: TextStyle(
                  fontFamily: "Champagne & Limousines",
                  fontSize: 18,
                  color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:8.0),
          child: Container(
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
        ),
        Spacer(flex: 1),
      ],
    );
  }
}

class SuggestedLocationCard extends StatelessWidget {
  const SuggestedLocationCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 110,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0)
                )
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0)
                )
              ),
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text('Bacon Spaces',style: TextStyle(fontWeight: FontWeight.bold),),
                        Text('Cebu City', style: TextStyle(color: Colors.grey),),
                      ],
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.location_on,size: 10),
                              Text('5km to [location]',style: TextStyle(fontSize: 10),)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Text('Php 25.00'),
                              Text('/ per hour')
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
