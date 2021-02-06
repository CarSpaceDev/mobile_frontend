import 'dart:async';
import 'dart:collection';

import 'package:android_intent/android_intent.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Lot.dart';
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
import 'package:shimmer/shimmer.dart';

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
    _initMapAssets();
    _initGeolocatorStream();
    WidgetsBinding.instance.addPostFrameCallback((_) async => Future.delayed(Duration(seconds: 2), () {
          if (vehicles.length > 0) _showVehicleDialog();
        }));
  }

  void _initMapAssets() {
    rootBundle.loadString('assets/mapPOI.txt').then((string) {
      _mapStylePOI = string;
    });
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    _setMarkerIcon();
  }

  void _initGeolocatorStream() {
    Geolocator.isLocationServiceEnabled().then((bool value) {
      if (value) {
        Geolocator.checkPermission().then((LocationPermission v) {
          if (v != null && v == LocationPermission.denied || v == LocationPermission.deniedForever) {
            Geolocator.requestPermission().then((LocationPermission locationPermission) {
              if (locationPermission != LocationPermission.denied && locationPermission != LocationPermission.deniedForever) startPositionStream();
            });
          } else {
            startPositionStream();
          }
        });
      } else {
        showLocationDisabledError();
      }
    });
  }

  Future showLocationDisabledError() {
    return showDialog(
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
      drawer: homeNavigationDrawer(context),
      backgroundColor: themeData.primaryColor,
      appBar: homeAppBar(
        context,
        "Map",
        NotificationLinkWidget(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !showLotCards
          ? FloatingActionButton(
              child: Text(lotsInRadius.length.toString()),
              onPressed: () {
                setState(() {
                  showLotCards = !showLotCards;
                });
              })
          : null,
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
                      myLocationButtonEnabled: false,
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
                    left: 8,
                    top: 8,
                    child: InkWell(
                      onTap: _showVehicleDialog,
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: new BoxDecoration(
                            color: themeData.primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.car_rental, color: Colors.white),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _selectedVehicle,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          )),
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
                          child: Icon(Icons.place, color: Colors.white, size: 25)),
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
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / (16 / 9),
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

  Drawer homeNavigationDrawer(BuildContext context) {
    return Drawer(
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
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: NotificationList(),
      ),
    );
  }

  startPositionStream() {
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 1, intervalDuration: Duration(seconds: 5))
            .listen(positionChangeHandler);
  }

  positionChangeHandler(Position v) {
    LatLng location = LatLng(v.latitude, v.longitude);
    driverMarker = Marker(markerId: MarkerId("user"), icon: _driverIcon, position: location);
    if (!showCrossHair) {
      mapController.moveCamera(CameraUpdate.newLatLng(new LatLng(location.latitude, location.longitude)));
    }
    getLotsInRadius(location);
  }

  Future<void> getLotsInRadius(LatLng location) async {
    _lotMarkers = [];
    List<Lot> resultLotsInRadius = [];
    locator<ApiService>().getLotsInRadius(latitude: location.latitude, longitude: location.longitude, kmRadius: 0.5).then((res) {
      if (res.statusCode == 200) {
        lotsLocated = res.body;
        for (var v in List<Map<String, dynamic>>.from(res.body)) {
          if (v['capacity'] == 0) continue;
          if (!checkIfDayIncluded(v['availableDays'])) continue;
          if (!checkIfWithinTime(v['availableFrom'], v['availableTo'])) continue;
          resultLotsInRadius.add(Lot.fromJson(v));
        }
        if (resultLotsInRadius.length > 0) {
          for (int i = 0; i < resultLotsInRadius.length; i++) {
            _lotMarkers.add(Marker(
                markerId: MarkerId(resultLotsInRadius[i].lotId),
                onTap: () {
                  setState(() {
                    showLotCards = false;
                  });
                  _showLotDialog(resultLotsInRadius[i]);
                },
                icon: _lotIcon,
                position: LatLng(resultLotsInRadius[i].coordinates[0], resultLotsInRadius[i].coordinates[1])));
          }
        }
        setState(() {
          showLotCards = false;
          lotsInRadius = resultLotsInRadius;
          _markers = Set.from([driverMarker] + _lotMarkers);
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

  locationSearchCallback(LocationSearchResult data) {
    mapController.animateCamera(CameraUpdate.newLatLng(data.location));
    searchPosition = data.location;
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

  Widget homeBottomNavBar() {
    return BottomAppBar(
      child: FlatButton(
        color: lotsInRadius.length == 0 ? themeData.secondaryHeaderColor : Colors.green,
        onPressed: () {
          checkBeforeReserve(lotsLocated);
        },
        child: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: lotsInRadius.length == 0 ? Colors.white : Colors.green,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
                child: Text(lotsInRadius.length == 0 ? "No lots nearby" : "PARK NOW",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: lotsInRadius.length == 0
                ? Icon(Icons.warning, color: Color.fromARGB(255, 0, 0, 0))
                : Icon(Icons.assistant_direction, color: Color.fromARGB(255, 0, 0, 0)),
            label: lotsInRadius.length == 0 ? "No lots nearby" : 'Lots found ' + lotsInRadius.length.toString()),
        BottomNavigationBarItem(icon: Icon(Icons.car_rental, color: Color.fromARGB(255, 0, 0, 0)), label: _selectedVehicle),
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
        ),
      ),
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
    if (index == 0) {
      setState(() {
        showLotCards = !showLotCards;
      });
    } else if (index == 1) {
      _showVehicleDialog();
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

        setState(() {
          _markers = Set.from([driverMarker] + _lotMarkers);
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
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                  child: AspectRatio(
                    aspectRatio: 2 / 2,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Select Default Vehicle", textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: vehicles.length,
                              itemBuilder: (BuildContext context, int index) => Card(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedVehicle = vehicles[index]['plateNumber'];
                                          selectedVehicleData = vehicles[index];
                                        });
                                        Navigator.of(context, rootNavigator: true).pop();
                                        showMessage("${vehicles[index]['plateNumber']} has been selected");
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
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text("Plate#: ${vehicles[index]['plateNumber']}", textAlign: TextAlign.start),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text("Make: ${vehicles[index]['make']} ", textAlign: TextAlign.start),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text("Model: ${vehicles[index]['model']}", textAlign: TextAlign.start),
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
    if (userData['currentReservation'] != null) return showMessage("Error: You have an ongoing reservation");

    for (var lots in v) {
      if (lots['capacity'] == 0) continue;
      if (lots['vehicleTypeAccepted'] < selectedVehicleData['type']) continue;
      if (!checkIfDayIncluded(lots['availableDays'])) continue;
      if (!checkIfWithinTime(lots['availableFrom'], lots['availableTo'])) continue;
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              child: new SizedBox(
                height: 500,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: LotFound(lotData, selectedVehicleData, userData)),
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
    var time = (now.hour * 100) + now.minute;
    print(time);
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
