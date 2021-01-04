import 'dart:async';
import 'dart:collection';

import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController mapController;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  BitmapDescriptor _destination;
  TextEditingController _searchController;
  bool showLotCards = false;
  bool showCrossHair = false;
  int selectedIndex = 0;
  StreamSubscription<Position> positionStream;
  LatLng currentLocation;
  LatLng searchPosition;
  Set<Marker> _markers = HashSet<Marker>();
  List<Marker> _lotMarkers = [];
  Marker driverMarker;
  Marker destinationMarker;
  List<dynamic> lotsInRadius = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: "");
    // rootBundle.loadString('assets/mapStyle.txt').then((string) {
    //   _mapStyle = string;
    // });
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
    _searchController.dispose();
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
      getLotsInRadius(location);
    }
    currentLocation = LatLng(location.latitude, location.longitude);
  }

  Future<void> getLotsInRadius(LatLng location) async {
    locator<ApiService>().getLotsInRadius(latitude: location.latitude, longitude: location.longitude, kmRadius: 0.5).then((res) {
      print(res.statusCode);
      if (res.statusCode == 200) {
        _lotMarkers = [];
        print(res.body);
        if (res.body.length > 0) {
          for (int i = 0; i < res.body.length; i++) {
            _lotMarkers.add(Marker(
                markerId: MarkerId(res.body[i]["lotId"]),
                onTap: () {
                  print(res.body[i]);
                  setState(() {
                    selectedIndex = i;
                    showLotCards = true;
                  });
                },
                icon: _lotIcon,
                position: LatLng(res.body[i]["coordinates"][0], res.body[i]["coordinates"][1])));
          }
        }
        setState(() {
          lotsInRadius = res.body;
          if (destinationMarker != null) {
            print("destinationMarker is not null");
            _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
          } else {
            print("destination marker is null");
            _markers = Set.from([driverMarker] + _lotMarkers);
          }
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // setState(() {
    //   mapController.setMapStyle(_mapStyle);
    // });
  }

  setSearchPositionMarker(LatLng coordinates) {
    setState(() {
      destinationMarker = Marker(
        markerId: MarkerId("destination"),
        position: coordinates,
        icon: _destination,
        onTap: () {
          print(searchPosition);
        },
      );
    });
  }

  locationSearchCallback(LocationSearchResult data) {
    print(data.toJson());
    mapController.animateCamera(CameraUpdate.newLatLng(data.location));
    searchPosition = data.location;
    setSearchPositionMarker(data.location);
    getLotsInRadius(data.location);
  }

  void _onCameraMove(CameraPosition d) {
    searchPosition = LatLng(d.target.latitude, d.target.longitude);
  }

  void _setMarkerIcon() async {
    _lotIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
    _driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png');
    _destination = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/destination.png');
  }

  AppBar homeAppBar(BuildContext context, String appBarTitle, Function onPressed) {
    return AppBar(
      backgroundColor: themeData.primaryColor,
      brightness: Brightness.dark,
      title: Text(appBarTitle),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {},
        child: Container(child: Icon(Icons.menu)),
      ),
      actions: <Widget>[
        IconButton(
          color: Colors.white,
          onPressed: onPressed,
          icon: Icon(Icons.exit_to_app),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 52),
        child: LocationSearchWidget(
          callback: locationSearchCallback,
          controller: _searchController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData.primaryColor,
      appBar: homeAppBar(context, "Map", () {
        context.read<LoginBloc>().add(LogoutEvent());
        locator<NavigationService>().pushReplaceNavigateTo(LoginRoute);
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: lotsInRadius.length == 0
                  ? Icon(Icons.warning, color: Color.fromARGB(255, 0, 0, 0))
                  : Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)),
              label: lotsInRadius.length == 0 ? "No lots nearby" : 'Lots found ' + lotsInRadius.length.toString()),
          BottomNavigationBarItem(icon: Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)), label: 'Show Destination'),
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed, color: Color.fromARGB(255, 0, 0, 0)), label: 'My Location')
        ],
        onTap: (index) {
          print(index);
          if (index == 1) {
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                target: searchPosition,
                zoom: 15.0,
              ),
            ));
          } else if (index == 2) {
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentLocation,
                zoom: 14.0,
              ),
            ));
          }
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: (e) {
                      setState(() {
                        showCrossHair = true;
                      });
                    },
                    onPointerUp: (e) {
                      Geocoder.google("AIzaSyATBKvXnZydsfNs8YaB7Kyb96-UDAkGujo")
                          .findAddressesFromCoordinates(Coordinates(searchPosition.latitude, searchPosition.longitude))
                          .then((addresses) {
                        print(addresses.first.addressLine);
                        setState(() {
                          _searchController.text = addresses.first.addressLine;
                        });
                      });
                      print("Moved camera, new position is ${searchPosition.toString()}");
                      destinationMarker = Marker(
                        markerId: MarkerId("destination"),
                        position: searchPosition,
                        icon: _destination,
                        draggable: true,
                      );
                      setState(() {
                        if (destinationMarker != null) {
                          print("destinationMarker is not null");
                          _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
                        } else {
                          print("destination marker is null");
                          _markers = Set.from([driverMarker] + _lotMarkers);
                        }
                        showCrossHair = false;
                      });
                      getLotsInRadius(searchPosition);
                    },
                    child: GoogleMap(
                      mapType: MapType.hybrid,
                      onCameraMove: _onCameraMove,
                      myLocationButtonEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(1, 1),
                        zoom: 15.0,
                      ),
                      markers: _markers,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      onTap: resetSearchTerm,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: new BoxDecoration(
                          color: themeData.primaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 66,
                    top: 8,
                    child: InkWell(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: new BoxDecoration(
                          color: themeData.primaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        child: Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                  showCrossHair
                      ? Positioned(
                          top: MediaQuery.of(context).size.height * .5 - 128.5,
                          left: MediaQuery.of(context).size.width * .5 - 16,
                          child: Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                ],
              ),
            ),
            lotsInRadius.length != 0
                ? Positioned(
                    bottom: SizeConfig.widthMultiplier * 8,
                    child: SizedBox(
                      width: SizeConfig.widthMultiplier * 100,
                      height: SizeConfig.heightMultiplier * 15,
                      child: PageView(
                        onPageChanged: (index) {
                          mapController?.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(lotsInRadius[index]["coordinates"][0], lotsInRadius[index]["coordinates"][1]),
                              zoom: 17.0,
                            ),
                          ));
                        },
                        controller: new PageController(),
                        children: generateLotCards(),
                      ),
                    ),
                  )
                : Container(
                    width: 0,
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }

  generateLotCards() {
    List<Widget> result = [];
    lotsInRadius.forEach((lot) {
      result.add(SuggestedLocationCard(
        name: lot["lotId"],
        address: lot["address"],
        price: double.parse(lot["pricing"].toString()),
        distance: lot["distance"],
      ));
    });
    return result;
  }

  void resetSearchTerm() {
    setState(() {
      _searchController.text = "";
    });
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentLocation,
        zoom: 15.0,
      ),
    ));
    destinationMarker = null;
    getLotsInRadius(currentLocation);
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
