import 'dart:async';
import 'dart:collection';

import 'package:android_intent/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Lot.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/screens/Home/LotFound.dart';
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
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'SuggestedLocationCard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mapStyle;
  String _mapStylePOI;
  bool showPointOfInterest;
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
  int _userAccess = 0;
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
  bool noVehicles;
  String _selectedVehicle = "";
  var selectedVehicleData;
  var lotsLocated;
  var vehicles = [];
  var userData;
  bool vehiclesLoaded = false;
  @override
  void initState() {
    super.initState();
    _populateVehicles();
    _initAccess();
    lotsLocated = 0;
    _selectedVehicle = "No Vehicle Selected";
    _searchController = TextEditingController(text: "");
    rootBundle.loadString('assets/mapPOI.txt').then((string) {
      _mapStylePOI = string;
    });
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
    Geolocator.isLocationServiceEnabled().then((bool value) {
      if (value) {
        Geolocator.checkPermission().then((v) {
          if (v != null ||
              v == LocationPermission.denied ||
              v == LocationPermission.deniedForever) {
            Geolocator.requestPermission().then((locationPermission) {
              if (locationPermission != LocationPermission.denied &&
                  locationPermission != LocationPermission.deniedForever)
                startPositionStream();
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
                actions: [
                  FlatButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text("Close"))
                ],
              );
            });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) async => Future.delayed(Duration(seconds: 3), () {
              if (vehicles.length > 0) _showVehicleDialog();
            }));
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
                    locator<NavigationService>()
                        .pushNavigateTo(VehicleManagement);
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
                      locator<NavigationService>()
                          .pushNavigateTo(PartnerReservations);
                    },
                    child: Text("Partner Reservations")),
              ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    locator<NavigationService>()
                        .pushReplaceNavigateTo(LoginRoute);
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
                      right: 205,
                      bottom: 40,
                      child: InkWell(
                          onTap: () {
                            checkBeforeReserve(lotsLocated);
                          },
                          child: Container(
                              width: 80,
                              height: 80,
                              decoration: new BoxDecoration(
                                color: themeData.primaryColor,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              child: Icon(Icons.airport_shuttle_rounded,
                                  color: Colors.white, size: 70)))),
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
                  Positioned(
                    right: 8,
                    top: 66,
                    child: InkWell(
                      onTap: _showPOI,
                      child: Container(
                          width: 50,
                          height: 50,
                          decoration: new BoxDecoration(
                            color: themeData.primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                          child:
                              Icon(Icons.place, color: Colors.white, size: 25)),
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
                    left: (MediaQuery.of(context).size.width -
                            (MediaQuery.of(context).size.height * .55)) /
                        2,
                    child: Container(
                      width: MediaQuery.of(context).size.height * .55,
                      height:
                          MediaQuery.of(context).size.height * .55 / (16 / 9),
                      child: Center(
                        child: PageView(
                          onPageChanged: (index) {
                            mapController
                                ?.animateCamera(CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    lotsInRadius[index].coordinates[0],
                                    lotsInRadius[index].coordinates[1]),
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

  _initAccess() async {
    String _uid = locator<AuthService>().currentUser().uid;
    await locator<ApiService>().getUserData(uid: _uid).then((data) {
      _partnerAccess = data.body['partnerAccess'];
      _userAccess = data.body['userAccess'];
      userData = data.body;
    });
  }

  showNotificationDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: NotificationList(),
      ),
    );
  }

  startPositionStream() {
    positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
            intervalDuration: Duration(seconds: 5))
        .listen(positionChangeHandler);
  }

  positionChangeHandler(Position v) {
    LatLng location = LatLng(v.latitude, v.longitude);
    driverMarker = Marker(markerId: MarkerId("user"), icon: _driverIcon, position: location);
    locator<MqttService>().send("test", location.toString());
    driverMarker = Marker(
        markerId: MarkerId("user"), icon: _driverIcon, position: location);
    if (currentLocation != null) {
      setState(() {
        if (destinationMarker != null) {
          _markers = Set.from([destinationMarker, driverMarker] + _lotMarkers);
        } else {
          _markers = Set.from([driverMarker] + _lotMarkers);
        }
      });
    } else {
      mapController.moveCamera(CameraUpdate.newLatLng(
          new LatLng(location.latitude, location.longitude)));
      if (destinationSearchMode) {
      } else {
        getLotsInRadius(location);
      }
    }
    currentLocation = LatLng(location.latitude, location.longitude);
  }

  Future<void> getLotsInRadius(LatLng location) async {
    locator<ApiService>()
        .getLotsInRadius(
            latitude: location.latitude,
            longitude: location.longitude,
            kmRadius: 0.5)
        .then((res) {
      if (res.statusCode == 200) {
        _lotMarkers = [];
        lotsInRadius = [];
        List<Map<String, dynamic>>.from(res.body).forEach((element) {
          lotsInRadius.add(Lot.fromJson(element));
          setState(() {
            lotsLocated = res.body;
          });
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
                position: LatLng(lotsInRadius[i].coordinates[0],
                    lotsInRadius[i].coordinates[1])));
          }
        }
        setState(() {
          if (destinationMarker != null) {
            _markers =
                Set.from([destinationMarker, driverMarker] + _lotMarkers);
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
      showPointOfInterest = false;
    });
  }

  _showPOI() {
    if (showPointOfInterest) {
      setState(() {
        mapController.setMapStyle(_mapStyle);
        showPointOfInterest = false;
      });
    } else {
      setState(() {
        mapController.setMapStyle(_mapStylePOI);
        showPointOfInterest = true;
      });
    }
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
    _lotIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)),
        'assets/launcher_icon/pushpin.png');
    _driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)),
        'assets/launcher_icon/driver.png');
    _destination = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(10, 10)),
        'assets/launcher_icon/destination.png');
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
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
                      : Icon(Icons.assistant_direction,
                          color: Color.fromARGB(255, 0, 0, 0)),
                  label: lotsInRadius.length == 0
                      ? "No lots nearby"
                      : 'Lots found ' + lotsInRadius.length.toString()),
              BottomNavigationBarItem(
                  icon: Icon(Icons.assistant_direction,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  label: 'Show Destination'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.car_rental,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  label: _selectedVehicle)
            ]
          : [
              BottomNavigationBarItem(
                  icon: lotsInRadius.length == 0
                      ? Icon(Icons.warning, color: Color.fromARGB(255, 0, 0, 0))
                      : Icon(Icons.assistant_direction,
                          color: Color.fromARGB(255, 0, 0, 0)),
                  label: lotsInRadius.length == 0
                      ? "No lots nearby"
                      : 'Lots found ' + lotsInRadius.length.toString()),
              BottomNavigationBarItem(
                  icon: Icon(Icons.car_rental,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  label: _selectedVehicle),
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
        _showVehicleDialog();
      }
    } else {
      if (index == 0) {
        setState(() {
          showLotCards = !showLotCards;
        });
      } else if (index == 1) {
        _showVehicleDialog();
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
            .findAddressesFromCoordinates(
                Coordinates(searchPosition.latitude, searchPosition.longitude))
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
            _markers =
                Set.from([destinationMarker, driverMarker] + _lotMarkers);
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
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.navigation:q=$lat,$lng'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  _populateVehicles() async {
    String _uid = locator<AuthService>().currentUser().uid;
    await locator<ApiService>().getVehicles(uid: _uid).then((data) {
      List<dynamic> vehiclesFromApi = new List.from(data.body);

      if (vehiclesFromApi.isEmpty) {
        noVehicles = true;
        vehiclesLoaded = true;
      } else {
        vehicles = data.body;
        setState(() {
          noVehicles = false;
          vehiclesLoaded = true;
        });
      }
    });
  }

  _showVehicleDialog() {
    if (vehicles.length < 0)
      return showMessage("No vehicles registered");
    else
      return showDialog(
          context: context,
          builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 200,
                width: 125,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                  child: AspectRatio(
                    aspectRatio: 2 / 2,
                    child: Column(
                      children: [
                        Container(
                            child: SizedBox(
                          height: 25,
                          width: 250,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white),
                            child: Text("Tap to select vehicle to use",
                                textAlign: TextAlign.center),
                          ),
                        )),
                        Expanded(
                          child: ListView.builder(
                              itemCount: vehicles.length,
                              itemBuilder: (BuildContext context, int index) =>
                                  Card(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedVehicle =
                                              vehicles[index]['plateNumber'];
                                          selectedVehicleData = vehicles[index];
                                        });
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        showMessage(
                                            "${vehicles[index]['plateNumber']} has been selected");
                                      },
                                      child: Row(children: [
                                        Row(
                                          children: [
                                            ClipRRect(
                                                child: Image.network(
                                              vehicles[index]['vehicleImage'],
                                              fit: BoxFit.fill,
                                              height: 100,
                                              width: 140,
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                      "Plate#: ${vehicles[index]['plateNumber']}",
                                                      textAlign:
                                                          TextAlign.start),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                      "Make: ${vehicles[index]['make']} ",
                                                      textAlign:
                                                          TextAlign.start),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                      "Model: ${vehicles[index]['model']}",
                                                      textAlign:
                                                          TextAlign.start),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ]),
                                    ),
                                  )),
                        ),
                      ],
                    ),
                  ),
                ),
              )));
  }

  checkBeforeReserve(dynamic v) {
    DateTime now = new DateTime.now();
    bool success = false;
    if (_userAccess < 210) {
      return showMessage("Error: Account not verified");
    }
    if (lotsLocated == 0) {
      return showMessage("Error: No available lots within your 500m radius");
    }
    if (noVehicles) {
      return showMessage("Error: No Vehicle on file");
    }
    if (_selectedVehicle == "No Vehicle Selected") {
      return showMessage("Error: No vehicle selected");
    }
    if (userData['currentReservation'] != null)
      return showMessage("Error: You have an ongoing reservation");

    for (var lots in v) {
      if (lots['capacity'] == 0) continue;
      if (lots['vehicleTypeAccepted'] < selectedVehicleData['type']) continue;
      if (!checkIfDayIncluded(lots['availableDays'])) continue;
      if (!checkIfWithinTime(lots['availableFrom'], lots['availableTo']))
        continue;
      success = true;
      _showQuickBook(lots['lotId'], _selectedVehicle, userData['uid']);
    }
    if (!success) {
      return showMessage("Error: No lots currently match the criteria");
    }
  }

  _showQuickBook(var lotData, var selectedVehicleData, var userData) {
    return showDialog(
        barrierDismissible: false,
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
                      child: LotFound(lotData, selectedVehicleData, userData)),
                ),
              ),
            ));
  }

  checkIfDayIncluded(dynamic v) {
    DateTime now = new DateTime.now();
    var returnValue = false;
    for (var day in v) {
      if (day == now.day) {
        returnValue = true;
        break;
      }
    }
    return returnValue;
  }

  checkIfWithinTime(dynamic v, dynamic x) {
    DateTime now = new DateTime.now();
    var time = now.hour * 100;
    if (time > int.parse(v) && time < int.parse(x))
      return true;
    else
      return false;
  }

  showMessage(dynamic v) {
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
}
