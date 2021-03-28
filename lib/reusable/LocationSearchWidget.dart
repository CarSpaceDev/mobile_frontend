import 'dart:io';

import 'package:carspace/services/ApiMapService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uuid/uuid.dart';

import '../serviceLocator.dart';

class LocationSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  LocationSearchWidget({Key key, this.callback, this.controller}) : super(key: key);
  final Function callback;

  @override
  _LocationSearchWidgetState createState() => _LocationSearchWidgetState(this.callback, this.controller);
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _controller;
  final Function callback;
  _LocationSearchWidgetState(this.callback, this._controller);
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: new BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.all(
          //   Radius.circular(25.0),
          // ),
        ),
        padding: EdgeInsets.only(left: 16, right: 16),
        child: TextField(
          controller: _controller,
          readOnly: true,
          onTap: () async {
            // generate a new token here
            final sessionToken = Uuid().v4();
            final Suggestion result = await showSearch(
              context: context,
              delegate: AddressSearch(sessionToken),
            );
            // This will change the text displayed in the TextField
            if (result != null) {
              final placeDetails = await PlaceApiProvider(sessionToken).getPlaceDetailFromId(result.placeId);
              setState(() {
                _controller.text = result.description;
              });
              if (callback != null) callback(placeDetails);
            }
          },
          decoration: InputDecoration(
            icon: Icon(
              Icons.map_outlined,
              color: Colors.black,
            ),
            hintText: "Enter Destination",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : apiClient.fetchSuggestions(query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text((snapshot.data[index] as Suggestion).description),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestion);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}

class Place {
  String streetNumber;
  String street;
  String city;
  String zipCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = 'AIzaSyATBKvXnZydsfNs8YaB7Kyb96-UDAkGujo';
  static final String iosKey = 'AIzaSyATBKvXnZydsfNs8YaB7Kyb96-UDAkGujo';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final response = await locator<ApiMapService>()
        .getAutoComplete(input: input, lang: lang, apiKey: apiKey, sessionToken: sessionToken);
    if (response.statusCode == 200) {
      final result = response.body;
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions'].map<Suggestion>((p) => Suggestion(p['place_id'], p['description'])).toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<LocationSearchResult> getPlaceDetailFromId(String placeId) async {
    if (placeId == "0") return null;
    GoogleMapsPlaces _places = new GoogleMapsPlaces(apiKey: apiKey); //Same API_KEY as above
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
    double latitude = detail.result.geometry.location.lat;
    double longitude = detail.result.geometry.location.lng;

    var components = detail.result.addressComponents;
    final place = Place();
    components.forEach((c) {
      if (c.types.contains('street_number')) {
        place.streetNumber = c.longName;
      }
      if (c.types.contains('route')) {
        place.street = c.longName;
      }
      if (c.types.contains('sublocality')) {
        place.city = c.longName;
      }
      if (c.types.contains('postal_code')) {
        place.zipCode = c.longName;
      }
    });
    return LocationSearchResult(latitude, longitude, locationDetails: place);
  }
}

class LocationSearchResult {
  Place locationDetails;
  LatLng location;

  LocationSearchResult(double latitude, double longitude, {this.locationDetails}) {
    this.location = new LatLng(latitude, longitude);
  }

  toJson() {
    return "${location.latitude} ${location.longitude} ${locationDetails.toString()}";
  }
}
