import 'dart:async';
import 'dart:collection';

import 'package:android_intent/android_intent.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Lot.dart';
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
  int _partnerAccess = 0;
  StreamSubscription<Position> positionStream;
  LatLng currentLocation;
  LatLng searchPosition;
  LatLng destinationPosition;
  Set<Marker> _markers = HashSet<Marker>();
  List<Marker> _lotMarkers = [];
  Marker driverMarker;
  Marker destinationMarker;
  List<Lot> lotsInRadius = [];
  PageController _pageController = new PageController();
  @override
  void initState() {
    super.initState();
    _initPartnerAccess();
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
      } else {
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
                            Icons.error,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                        Text(
                          "Location Services Disabled. Please enable it and restart CarSpace",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
                actions: [FlatButton(onPressed: Navigator.of(context).pop, child: Text("Close"))],
              );
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
            if (_partnerAccess == 0)
              Container(
                child: Center(
                    child: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        backgroundColor: themeData.primaryColor,
                      ),
                      Text(
                        "Loading",
                        style: TextStyle(color: themeData.primaryColor),
                      )
                    ],
                  ),
                )),
              )
            else
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
              title: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    locator<NavigationService>().pushNavigateTo(Reservations);
                  },
                  child: Text("Reservations")),
            ),
            if (_partnerAccess > 200)
              ListTile(
                title: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      locator<NavigationService>().pushNavigateTo(PartnerReservations);
                    },
                    child: Text("Partner Reservations")),
              ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    locator<NavigationService>().pushReplaceNavigateTo(LoginRoute);
                    context.read<LoginBloc>().add(LogoutEvent());
                  },
                  child: Text("Sign Out")),
            ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    locator<NavigationService>().pushNavigateTo(BetaFunctions);
                  },
                  child: Text("Beta Functions")),
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
                    left: (MediaQuery.of(context).size.width - (MediaQuery.of(context).size.height * .55)) / 2,
                    child: Container(
                      width: MediaQuery.of(context).size.height * .55,
                      height: MediaQuery.of(context).size.height * .55 / (16 / 9),
                      child: Center(
                        child: PageView(
                          onPageChanged: (index) {
                            mapController?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(lotsInRadius[index].coordinates[0], lotsInRadius[index].coordinates[1]),
                                zoom: 17.0,
                              ),
                            ));
                          },
                          controller: _pageController,
                          children: generateLotCards(),
                        ),
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

  _initPartnerAccess() async {
    var uid = locator<AuthService>().currentUser().uid;
    await locator<ApiService>().getVerificationStatus(uid: uid).then((data) {
      _partnerAccess = data.body['partnerAccess'];
    });
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
    driverMarker = Marker(markerId: MarkerId("user"), icon: _driverIcon, position: location);
    if (currentLocation != null) {
      setState(() {
        if (destinationMarker != null) {
          _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
        } else {
          _markers = Set.from([driverMarker] + _lotMarkers);
        }
      });
    } else {
      mapController.moveCamera(CameraUpdate.newLatLng(new LatLng(location.latitude, location.longitude)));
      if (destinationSearchMode) {
      } else {
        getLotsInRadius(location);
      }
    }
    currentLocation = LatLng(location.latitude, location.longitude);
  }

  Future<void> getLotsInRadius(LatLng location) async {
    locator<ApiService>().getLotsInRadius(latitude: location.latitude, longitude: location.longitude, kmRadius: 0.5).then((res) {
      if (res.statusCode == 200) {
        _lotMarkers = [];
        lotsInRadius = [];
        List<Map<String, dynamic>>.from(res.body).forEach((element) {
          lotsInRadius.add(Lot.fromJson(element));
        });
        if (lotsInRadius.length > 0) {
          for (int i = 0; i < lotsInRadius.length; i++) {
            _lotMarkers.add(Marker(
                markerId: MarkerId(lotsInRadius[i].lotId),
                onTap: () {
                  setState(() {
                    showLotCards = false;
                  });
                  _showLotDialog(lotsInRadius[i]);
                },
                icon: _lotIcon,
                position: LatLng(lotsInRadius[i].coordinates[0], lotsInRadius[i].coordinates[1])));
          }
        }
        setState(() {
          if (destinationMarker != null) {
            _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
          } else {
            _markers = Set.from([driverMarker] + _lotMarkers);
          }
        });
      }
    });
  }

  _showLotDialog(Lot v) {
    return showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: SuggestedLocationCard(
                  lot: v,
                  callback: () {
                    _showReservationDialog(v.lotId);
                  },
                ),
              ),
            ));
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
      if (searchPosition != null) {
        setState(() {
          showCrossHair = true;
        });
      }
    }
  }

  void mapOnPointerUp(e) {
    if (!destinationLocked) {
      if (searchPosition != null) {
        Geocoder.google("AIzaSyATBKvXnZydsfNs8YaB7Kyb96-UDAkGujo")
            .findAddressesFromCoordinates(Coordinates(searchPosition.latitude, searchPosition.longitude))
            .then((addresses) {
          setState(() {
            _searchController.text = addresses.first.addressLine;
          });
        });
        destinationMarker = Marker(
          markerId: MarkerId("destination"),
          position: searchPosition,
          icon: _destination,
          draggable: true,
        );
        setState(() {
          if (destinationMarker != null) {
            _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
          } else {
            _markers = Set.from([driverMarker] + _lotMarkers);
          }
          showCrossHair = false;
        });
        getLotsInRadius(searchPosition);
      }
    }
  }

  generateLotCards() {
    List<Widget> result = [];
    lotsInRadius.forEach((lot) {
      result.add(
        SuggestedLocationCard(
          lot: lot,
          callback: () {
            _showReservationDialog(lot.lotId);
          },
        ),
      );
    });
    return result;
  }

  navigateViaGoogleMaps(double lat, double lng) {
    final AndroidIntent intent =
        AndroidIntent(action: 'action_view', data: Uri.encodeFull('google.navigation:q=$lat,$lng'), package: 'com.google.android.apps.maps');
    intent.launch();
  }
}
