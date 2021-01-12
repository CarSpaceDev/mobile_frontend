import 'dart:async';
import 'dart:collection';

import 'package:android_intent/android_intent.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/Home/NotificationLinkWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../serviceLocator.dart';
import 'LotReservation.dart';
import 'NotificationList.dart';
import 'SuggestedLocationCard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mapStyle;
  GoogleMapController mapController;
  BitmapDescriptor _lotIcon;
  BitmapDescriptor _driverIcon;
  BitmapDescriptor _destination;
  TextEditingController _searchController;
  bool showLotCards = false;
  bool showCrossHair = false;
  bool destinationLocked = false;
  bool destinationSearchMode = false;
  int selectedIndex = 0;
  StreamSubscription<Position> positionStream;
  LatLng currentLocation;
  LatLng searchPosition;
  LatLng destinationPosition;
  Set<Marker> _markers = HashSet<Marker>();
  List<Marker> _lotMarkers = [];
  Marker driverMarker;
  Marker destinationMarker;
  List<dynamic> lotsInRadius = [];
  PageController _pageController = new PageController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(locator<AuthService>().currentUser().displayName),
            ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    showNotificationDialog();
                  },
                  child: Text("Notifications")),
            ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    locator<NavigationService>().pushNavigateTo(VehicleManagement);
                  },
                  child: Text("Vehicles")),
            ),
            ListTile(
              title: Text("Reservations"),
            ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    locator<NavigationService>().pushReplaceNavigateTo(LoginRoute);
                    context.read<LoginBloc>().add(LogoutEvent());
                  },
                  child: Text("Sign Out")),
            ),
          ],
        ),
      ),
      backgroundColor: themeData.primaryColor,
      appBar: homeAppBar(
        context,
        "Map",
        NotificationLinkWidget(),
      ),
      bottomNavigationBar: homeBottomNavBar(),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: mapOnPointerDown,
                    onPointerUp: mapOnPointerUp,
                    child: GoogleMap(
                      onCameraMove: _onCameraMove,
                      myLocationButtonEnabled: true,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: true,
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
                      onTap: autoCompleteWidgetAction,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: new BoxDecoration(
                          color: themeData.primaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        child: destinationLocked
                            ? Icon(Icons.clear, color: Colors.white, size: 25)
                            : Icon(
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
            lotsInRadius.length != 0 && showLotCards
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
                        controller: _pageController,
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

  showNotificationDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: NotificationList(),
      ),
    );
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
      setState(() {
        if (destinationMarker != null) {
          print("destinationMarker is not null");
          _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
        } else {
          print("destination marker is null");
          _markers = Set.from([driverMarker] + _lotMarkers);
        }
      });
    } else {
      mapController.moveCamera(CameraUpdate.newLatLng(new LatLng(location.latitude, location.longitude)));
      if (destinationSearchMode) {
      } else {
        print("Car should move");
        getLotsInRadius(location);
      }
    }
    currentLocation = LatLng(location.latitude, location.longitude);
  }

  Future<void> getLotsInRadius(LatLng location) async {
    locator<ApiService>().getLotsInRadius(latitude: location.latitude, longitude: location.longitude, kmRadius: 0.5).then((res) {
      print(res.statusCode);
      if (res.statusCode == 200) {
        _lotMarkers = [];
        if (res.body.length > 0) {
          for (int i = 0; i < res.body.length; i++) {
            _lotMarkers.add(Marker(
                markerId: MarkerId(res.body[i]["lotId"]),
                onTap: () {
                  setState(() {
                    showLotCards = true;
                  });
                  _pageController.jumpToPage(i);
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
    setState(() {
      mapController.setMapStyle(_mapStyle);
    });
  }

  setSearchPositionMarker(LatLng coordinates) {
    destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: coordinates,
      icon: _destination,
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
    searchPosition = LatLng(d.target.latitude, d.target.longitude);
  }

  void _setMarkerIcon() async {
    _lotIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/pushpin.png');
    _driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/driver.png');
    _destination = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(10, 10)), 'assets/launcher_icon/destination.png');
  }

  void autoCompleteWidgetAction() {
    if (destinationLocked) {
      setState(() {
        destinationLocked = false;
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
    } else {
      if (_searchController.text != "")
        setState(() {
          destinationLocked = true;
          destinationPosition = searchPosition;
        });
    }
  }

  _showReservationDialog(dynamic lotId) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: new SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: LotReservation(lotId)),
                ),
              ),
            ));
  }

  BottomNavigationBar homeBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: destinationPosition != null
          ? [
              BottomNavigationBarItem(
                  icon: lotsInRadius.length == 0
                      ? Icon(Icons.warning, color: Color.fromARGB(255, 0, 0, 0))
                      : Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)),
                  label: lotsInRadius.length == 0 ? "No lots nearby" : 'Lots found ' + lotsInRadius.length.toString()),
              BottomNavigationBarItem(icon: Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)), label: 'Show Destination'),
              BottomNavigationBarItem(icon: Icon(Icons.gps_fixed, color: Color.fromARGB(255, 0, 0, 0)), label: 'My Location')
            ]
          : [
              BottomNavigationBarItem(
                  icon: lotsInRadius.length == 0
                      ? Icon(Icons.warning, color: Color.fromARGB(255, 0, 0, 0))
                      : Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)),
                  label: lotsInRadius.length == 0 ? "No lots nearby" : 'Lots found ' + lotsInRadius.length.toString()),
              BottomNavigationBarItem(icon: Icon(Icons.gps_fixed, color: Color.fromARGB(255, 0, 0, 0)), label: 'My Location'),
            ],
      onTap: bottomNavBarCallBack,
    );
  }

  AppBar homeAppBar(BuildContext context, String appBarTitle, Widget action) {
    return AppBar(
      backgroundColor: themeData.primaryColor,
      brightness: Brightness.dark,
      title: Text(appBarTitle),
      centerTitle: true,
      leading: Builder(
          builder: (context) => InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(child: Icon(Icons.menu)),
              )),
      actions: <Widget>[action],
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 52),
        child: LocationSearchWidget(
          callback: locationSearchCallback,
          controller: _searchController,
        ),
      ),
    );
  }

  void bottomNavBarCallBack(index) {
    print(index);
    if (destinationPosition != null) {
      if (index == 0) {
        setState(() {
          showLotCards = !showLotCards;
        });
      } else if (index == 1) {
        if (destinationPosition != null) {
          mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: destinationPosition,
              zoom: 15.0,
            ),
          ));
        }
      } else if (index == 2) {
        mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 14.0,
          ),
        ));
      }
    } else {
      if (index == 0) {
        setState(() {
          showLotCards = !showLotCards;
        });
      } else if (index == 1) {
        mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 14.0,
          ),
        ));
      }
    }
  }

  void mapOnPointerDown(e) {
    if (!destinationLocked) {
      setState(() {
        showCrossHair = true;
      });
    }
  }

  void mapOnPointerUp(e) {
    if (!destinationLocked) {
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
    }
  }

  generateLotCards() {
    List<Widget> result = [];
    lotsInRadius.forEach((lot) {
      print(lot);
      result.add(SuggestedLocationCard(
        name: lot["address"],
        address: "Available hours " + lot["availableFrom"].toString() + " - " + lot["availableTo"],
        price: double.parse(lot["pricing"].toString()),
        distance: lot["distance"],
        callback: () {
          _showReservationDialog(lot["lotId"]);
          // print("calling intent");
          // navigateViaGoogleMaps(lot["coordinates"][0], lot["coordinates"][1]);
        },
      ));
    });
    return result;
  }

  navigateViaGoogleMaps(double lat, double lng) {
    final AndroidIntent intent =
        AndroidIntent(action: 'action_view', data: Uri.encodeFull('google.navigation:q=$lat,$lng'), package: 'com.google.android.apps.maps');
    intent.launch();
  }
}
