import 'dart:async';
import 'dart:collection';

import 'package:android_intent/android_intent.dart';
import 'package:carspace/blocs/login/login_bloc.dart';
import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/constants/SizeConfig.dart';
import 'package:carspace/model/Vehicle.dart';
import 'package:carspace/navigation.dart';
import 'package:carspace/reusable/LocationSearchWidget.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:carspace/services/PushMessagingService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  StreamSubscription notificationSubscription;
  @override
  void initState() {
    super.initState();
    notificationSubscription =
        locator<PushMessagingService>().notificationStream.listen((event) {
      print("new event from stream");
      print(event);
    });
    _searchController = TextEditingController(text: "");
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
      }
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    _searchController.dispose();
    notificationSubscription.cancel();
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
              child: Text("Profile"),
            ),
            ListTile(
              title: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showNotificationDialog();
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
              title: Text("Reservations"),
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
      appBar: homeAppBar(context, "Map", () {
        _showNotificationDialog();
      }),
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
                          mapController
                              ?.animateCamera(CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                  lotsInRadius[index]["coordinates"][0],
                                  lotsInRadius[index]["coordinates"][1]),
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

  startPositionStream() {
    positionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
            intervalDuration: Duration(seconds: 15))
        .listen(positionChangeHandler);
  }

  positionChangeHandler(Position v) {
    LatLng location = LatLng(v.latitude, v.longitude);
    print("Updating Location: ${location.latitude}, ${location.longitude}");
    driverMarker = Marker(
        markerId: MarkerId("user"), icon: _driverIcon, position: location);
    if (currentLocation != null) {
      print(Geolocator.distanceBetween(currentLocation.latitude,
              currentLocation.longitude, location.latitude, location.longitude)
          .toStringAsFixed(5));
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
      mapController.moveCamera(CameraUpdate.newLatLng(
          new LatLng(location.latitude, location.longitude)));
      if (destinationSearchMode) {
      } else {
        print("Car should move");
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
                position: LatLng(res.body[i]["coordinates"][0],
                    res.body[i]["coordinates"][1])));
          }
        }
        setState(() {
          lotsInRadius = res.body;
          if (destinationMarker != null) {
            print("destinationMarker is not null");
            _markers =
                Set.from([destinationMarker, driverMarker] + _lotMarkers);
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

  _showNotificationDialog() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: new SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: NotificationList()),
                ),
              ),
            ));
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
                  icon: Icon(Icons.gps_fixed,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  label: 'My Location')
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
                  icon: Icon(Icons.gps_fixed,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  label: 'My Location'),
            ],
      onTap: bottomNavBarCallBack,
    );
  }

  AppBar homeAppBar(
      BuildContext context, String appBarTitle, Function onPressed) {
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
      actions: <Widget>[
        IconButton(
            color: Colors.white,
            onPressed: onPressed,
            icon: Icon(Icons.notifications)),
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
          .findAddressesFromCoordinates(
              Coordinates(searchPosition.latitude, searchPosition.longitude))
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
      result.add(SuggestedLocationCard(
        name: lot["lotId"],
        address: lot["address"],
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
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.navigation:q=$lat,$lng'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }
}

class SuggestedLocationCard extends StatelessWidget {
  final String name;
  final String address;
  final double price;
  final double distance;
  final Function callback;
  SuggestedLocationCard(
      {Key key,
      this.name,
      this.address,
      this.price,
      this.distance,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .15,
      child: Card(
        elevation: 6.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                  InkWell(
                      onTap: callback,
                      child:
                          Text("Select Lot", style: TextStyle(fontSize: 16))),
                  Text("${price.toStringAsFixed(2)}/hour",
                      style: TextStyle(fontSize: 16))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: ListView.builder(
                itemCount: 15,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Parking space is now available',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                'Jan. 07,2020 12:33 pm',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 10),
                              )
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Icon(Icons.more_horiz),
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Positioned(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close)),
              ],
            ),
          )),
        ],
      ),
    ));
  }
}

class LotReservation extends StatefulWidget {
  final lotId;
  const LotReservation(this.lotId);
  @override
  _LotReservationState createState() => _LotReservationState();
}

class _LotReservationState extends State<LotReservation> {
  Future<dynamic> _lotData;
  List<Vehicle> vehicles = [];
  var _verificationStatus;
  var _lotId;
  var _partnerId;
  var _userId;
  var namedDays;
  var _fullLotData;
  var selectedVehicle = "No Vehicle Selected";
  bool noVehicles = false;

  @override
  void initState() {
    super.initState();
    _lotData = _getLotData(widget.lotId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Stack(
        children: <Widget>[
          FutureBuilder<dynamic>(
            future: _lotData,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                namedDays = daysToNamedDays(snapshot.data['availableDays']);
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 25, bottom: 8, right: 8, left: 8),
                          child: Text(
                            '${snapshot.data['address']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              snapshot.data['lotImage'],
                              fit: BoxFit.fill,
                              height: 150,
                              width: 250,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Rating : \n${_verificationStatus}",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              "Price :\n${snapshot.data['pricing']} Php / Hour",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Availabile Days :\n${namedDays}",
                              textAlign: TextAlign.center),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              "Availabile from: \n${snapshot.data['availableFrom']}H - ${snapshot.data['availableTo']}H ",
                              textAlign: TextAlign.center),
                        ),
                        if (!noVehicles)
                          vehiclesPresent()
                        else
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, right: 4, left: 4, bottom: 4),
                            child: Text(
                                "No vehicles on file. Please register a vehicle to reserve a lot ",
                                textAlign: TextAlign.center),
                          ),
                      ],
                    )),
                    if (!noVehicles)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FlatButton(
                              onPressed: () {
                                if (selectedVehicle == "No Vehicle Selected")
                                  _vehicleCheck();
                                else
                                  _reserveButton();
                              },
                              color: themeData.secondaryHeaderColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Container(
                                width: SizeConfig.widthMultiplier * 50,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'Next',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize:
                                              SizeConfig.textMultiplier * 2.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              } else {
                return Container(
                  child: Center(
                      child: Container(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: themeData.primaryColor,
                        ),
                        Text(
                          "Loading",
                          style: TextStyle(color: themeData.primaryColor),
                        )
                      ],
                    ),
                  )),
                );
              }
            },
          ),
          Positioned(
              child: Padding(
            padding:
                const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Reserve Lot',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close)),
              ],
            ),
          )),
        ],
      ),
    ));
  }

  daysToNamedDays(dynamic data) {
    var numberDays = data;
    var numberToNamed = [];
    var namedToString;
    var namedDays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    if (numberDays.length == 7) {
      return namedToString = 'Everyday';
    } else {
      for (var i = 0; i < numberDays.length; i++) {
        numberToNamed.add(namedDays[numberDays[i]]);
      }
      namedToString = numberToNamed.join(', ').toString();
      return namedToString;
    }
  }

  Future<void> _vehicleCheck() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select a vehicle'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _reserveButton() async {
    var choice = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          if (_verificationStatus < 210) {
            return AlertDialog(
              title: Text('Error Proceeding'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'Error proceeding to type selection - please have your account verified'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          } else {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please select type'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Back'),
                  onPressed: () {
                    Navigator.of(context).pop(2);
                  },
                ),
                TextButton(
                  child: Text('Book'),
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                ),
                TextButton(
                  child: Text('Reserve'),
                  onPressed: () {
                    Navigator.of(context).pop(0);
                  },
                ),
              ],
            );
          }
        });
    if (choice == 0) {
      var body = ({
        "userId": _userId,
        "lotId": _lotId,
        "partnerId": _partnerId,
        "vehicleId": selectedVehicle,
        "reservationType": 0
      });
      print(body);
      await locator<ApiService>().reserveLot(body).then((value) {
        Navigator.of(context).pop();
        showMessage(value.body);
      }).catchError((err) {
        print(err);
      });
    } else if (choice == 1) {
      var body = ({
        "userId": _userId,
        "lotId": _lotId,
        "partnerId": _partnerId,
        "vehicleId": selectedVehicle,
        "reservationType": 1
      });
      print(body);
      await locator<ApiService>().reserveLot(body).then((value) {
        Navigator.of(context).pop();
        if (value.body == "Reservation Success") {
          showMessageAndUseIntent("Lot Booked");
        } else {
          showMessage(value.body);
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      print('Back');
    }
  }

  navigateViaGoogleMaps(double lat, double lng) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.navigation:q=$lat,$lng'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  showMessageAndUseIntent(dynamic v) {
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
                      "$v \n",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(context).pop, child: Text("Close")),
              FlatButton(
                child: Text("Navigate to Lot"),
                onPressed: () {
                  navigateViaGoogleMaps(
                      _fullLotData['g']['geopoint']['_latitude'],
                      _fullLotData['g']['geopoint']['_longitude']);
                },
              )
            ],
          );
        });
  }

  void showMessage(dynamic v) {
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
                  onPressed: Navigator.of(context).pop, child: Text("Close"))
            ],
          );
        });
  }

  Future<dynamic> _getLotData(lotId) async {
    var returnData;
    await _initData();
    await locator<ApiService>().getLot(uid: lotId).then((res) async {
      returnData = res.body;
      _lotId = res.body['lotId'];
      _partnerId = res.body['partnerId'];
      _fullLotData = res.body;
      print(_fullLotData);
    });
    return returnData;
  }

  Future<dynamic> _initData() async {
    var uid = locator<AuthService>().currentUser().uid;
    var returnData;
    _userId = uid;
    populateVehicles();
    await locator<ApiService>().getVerificationStatus(uid: uid).then((data) {
      _verificationStatus = data.body['userAccess'];
      returnData = data.body;
    });
    return returnData;
  }

  Future<dynamic> populateVehicles() {
    locator<ApiService>().getVehicles(uid: _userId).then((data) {
      List<dynamic> vehiclesFromApi = new List.from(data.body);
      if (vehiclesFromApi.isEmpty) {
        noVehicles = true;
      } else {
        vehiclesFromApi.forEach((data) {
          vehicles.add(Vehicle.fromJson(data));
        });
        noVehicles = false;
      }
    });
  }

  Widget vehiclesPresent() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        child:
            Text("----------------------------", textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 0),
        child: Text("Selected Vehicle: $selectedVehicle ",
            textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 0),
        child: Text("Select Vehicle :", textAlign: TextAlign.center),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 0, left: 4, right: 4, bottom: 0),
          child: setupAlertDialogueContainer()),
    ]);
  }

  setupAlertDialogueContainer() {
    return Container(
      height: 40.0, // Change as per your requirement
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: vehicles.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => Card(
            child: InkWell(
          onTap: () {
            setState(() {
              selectedVehicle = vehicles[index].plateNumber;
            });
          },
          child: Center(
            child: Text(vehicles[index].plateNumber),
          ),
        )),
      ),
    );
  }
}
