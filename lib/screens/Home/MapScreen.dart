import 'dart:async';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/screens/ReservationScreen/ReservationScreen.dart';
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
  bool options = false;
  bool suggestedLocation = false;
  ApiService _apiService = ApiService.create();
  bool workingMap = true;
  List<dynamic> lotsInRadius;
  bool lotsMarked = false;
  int selectedIndex;
  PickResult selectedPlace;
  StreamSubscription<LocationData> locationSubscription;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: "");
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    locationSubscription = location.onLocationChanged.listen((location) async {
      devLog("LocationUpdate",
          "Updating location : [" + location.latitude.toString() + ',' + location.longitude.toString() + ']');
      if (lotsInRadius == null) {
        var lots = await _apiService
            .findLotsFromRadius({"latitude": location.latitude, "longitude": location.longitude, "radius": 2000});
        print({"latitude": location.latitude, "longitude": location.longitude, "radius": 1500});
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
        for (int i = 0; i < lotsInRadius.length; i++) {
          _markers.add(
            Marker(
                markerId: MarkerId("Lot Result $i"),
                position: LatLng(
                    lotsInRadius[i]["location"]["coordinates"][1], lotsInRadius[i]["location"]["coordinates"][0]),
                icon: _lotIcon,
                onTap: () {
                  setState(() {
                    selectedIndex = i;
                  });
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

  setOptions() {
    setState(() {
      this.options = true;
      this.suggestedLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          mapController?.moveCamera(CameraUpdate.newCameraPosition(
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
          suggestedLocation
              ? Positioned(
                  bottom: SizeConfig.widthMultiplier * 22,
                  left: SizeConfig.widthMultiplier * 10,
                  right: SizeConfig.widthMultiplier * 10,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                      },
                      child: SuggestedLocationCard(
                        name: lotsInRadius[selectedIndex]["address"]["streetAddress"],
                        address: lotsInRadius[selectedIndex]["address"]["addressLocality"] +
                            " , " +
                            lotsInRadius[selectedIndex]["address"]["addressRegion"],
                        price: double.parse(lotsInRadius[selectedIndex]["pricing"].toString()),
                        distance: lotsInRadius[selectedIndex]["dist"]["calculated"],
                      )),
                )
              : Container()
        ],
      ),
    );
  }

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
              border: InputBorder.none,
              hintText: "Enter destination",
              hintStyle: TextStyle(fontFamily: "Champagne & Limousines", fontSize: 18, color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
  final String name;
  final String address;
  final double price;
  final double distance;
  SuggestedLocationCard({
    Key key,
    this.name,
    this.address,
    this.price,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          children: <Widget>[
            Container(
              width: 160,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0))),
              child: Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Subterranean_parking_lot.jpg/440px-Subterranean_parking_lot.jpg"),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0))),
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text(
                          name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          address,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 8),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.location_on, size: 16),
                              Text(
                                '${distance.toStringAsFixed(2)} m',
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16, left: 8),
                          child: Row(
                            children: <Widget>[Text(price.toStringAsFixed(2)), Text('/ per hour')],
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
