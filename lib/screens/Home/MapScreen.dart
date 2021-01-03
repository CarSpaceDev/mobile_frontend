import 'dart:async';
import 'dart:collection';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/ReservationScreen/ReservationScreen.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../serviceLocator.dart';

String _mapStyle;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  BitmapDescriptor _destination;
  TextEditingController _searchController;
  bool options = false;
  bool suggestedLocation = false;
  bool workingMap = true;
  bool lotsMarked = false;
  int selectedIndex = 0;
  StreamSubscription<Position> positionStream;
  LatLng currentLocation;
  LatLng searchPosition;
  Set<Marker> _markers = HashSet<Marker>();
  List<Marker> _lotMarkers = [];
  Marker driverMarker;
  Marker destinationMarker;
  List<dynamic> lotsInRadius;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: "");
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    Geolocator.isLocationServiceEnabled().then((bool value) {
      if (value) {
        Geolocator.checkPermission().then((v) {
          if (v != null || v == LocationPermission.denied || v == LocationPermission.deniedForever) {
            Geolocator.requestPermission().then((locationPermission) {
              if (locationPermission != LocationPermission.denied && locationPermission != LocationPermission.deniedForever) startPositionStream();
            });
          } else {
            startPositionStream();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  startPositionStream() {
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1, intervalDuration: Duration(seconds: 15))
            .listen(positionChangeHandler);
  }

  positionChangeHandler(Position v) {
    LatLng location = LatLng(v.latitude, v.longitude);
    print("Updating Location: ${location.latitude}, ${location.longitude}");
    driverMarker = Marker(markerId: MarkerId("user"), icon: _driverIcon, position: location);
    if (currentLocation != null) {
      print(Geolocator.distanceBetween(currentLocation.latitude, currentLocation.longitude, location.latitude, location.longitude).toStringAsFixed(5));
    } else {
      mapController.moveCamera(CameraUpdate.newLatLng(new LatLng(location.latitude, location.longitude)));
    }
    getLotsInRadius(location);
    currentLocation = LatLng(location.latitude, location.longitude);
  }

  void getLotsInRadius(LatLng location) {
    locator<ApiService>().getLotsInRadius(latitude: location.latitude, longitude: location.longitude, kmRadius: 1).then((res) {
      if (res.statusCode == 200) {
        if (res.body.length > 0) {
          _lotMarkers = [];
          for (int i = 0; i < res.body.length; i++) {
            _lotMarkers.add(Marker(
                markerId: MarkerId(res.body[i]["lotId"]),
                onTap: () {
                  print(res.body[i]);
                  setState(() {
                    selectedIndex = i;
                    suggestedLocation = true;
                  });
                },
                icon: _lotIcon,
                position: LatLng(res.body[i]["coordinates"][0], res.body[i]["coordinates"][1])));
          }
        }
      }
      setState(() {
        lotsInRadius = res.body;
        if (destinationMarker != null) {
          print("destinationMarker is not null");
          _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
        } else
          _markers = Set.from([driverMarker] + _lotMarkers);
      });
      print(res.body);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      mapController.setMapStyle(_mapStyle);
    });
  }

  setSearchPositionMarker(LatLng coordinates) {
    setState(() {
      destinationMarker = Marker(
        markerId: MarkerId("destination"),
        position: coordinates,
        icon: _destination,
        draggable: true,
        onDragEnd: (e) {
          getLotsInRadius(e);
          setState(() {
            searchPosition = e;
          });
        },
        onTap: () {
          print(searchPosition);
        },
      );
      _markers = Set.from([driverMarker, destinationMarker] + _lotMarkers);
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
            mapType: MapType.hybrid,
            onCameraMove: _onCameraMove,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(1, 1),
              zoom: 18.0,
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
                child: LocationSearchWidget(
                  callback: locationSearchCallback,
                ),
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
                          mapController?.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: currentLocation,
                              zoom: 17.0,
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
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ReservationScreen()));
                      },
                      child: SuggestedLocationCard(
                        name: lotsInRadius[selectedIndex]["lotId"],
                        address: lotsInRadius[selectedIndex]["address"],
                        price: double.parse(lotsInRadius[selectedIndex]["pricing"].toString()),
                        distance: lotsInRadius[selectedIndex]["distance"],
                      )),
                )
              : Container()
        ],
      ),
    );
  }

  locationSearchCallback(LocationSearchResult data) {
    print(data.toJson());
    mapController.animateCamera(CameraUpdate.newLatLng(data.location));
    searchPosition = data.location;
    setSearchPositionMarker(data.location);
    getLotsInRadius(data.location);
  }

  void _onCameraMove(CameraPosition d) {
    print(d.target);
    setState(() {
      searchPosition = LatLng(d.target.latitude, d.target.longitude);
    });
  }

  void _setMarkerIcon() async {
    _lotIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
    _driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png');
    _destination = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/destination.png');
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
            style: TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter destination",
              hintStyle: TextStyle(fontSize: 18, color: Colors.black),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .15,
      child: Card(
        elevation: 6.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                address,
                style: TextStyle(color: Colors.grey),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.location_on, size: 16),
                      Text(
                        '${distance.toStringAsFixed(2)} km',
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  Text("${price.toStringAsFixed(2)}/hour")
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
