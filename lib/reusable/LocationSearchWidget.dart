import 'dart:io';

import 'package:carspace/CSMap/bloc/classes.dart';
import 'package:carspace/services/ApiMapService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uuid/uuid.dart';

class LocationSearchService {
  static Future<LocationSearchResult> findLocation(BuildContext context) async {
    final sessionToken = Uuid().v4();
    final Suggestion result = await showSearch(
      context: context,
      delegate: AddressSearch(sessionToken),
    );
    if (result != null) {
      final LocationSearchResult placeDetails =
          await PlaceApiProvider(sessionToken)
              .getPlaceDetailFromId(result.placeId);
      return placeDetails;
    } else
      return null;
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
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text((snapshot.data[index] as Suggestion).description),
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
  String name;

  Place({this.streetNumber, this.street, this.city, this.zipCode, this.name});

  @override
  String toString() {
    return '${streetNumber!=null? streetNumber+', ':''}${street!=null? street+', ':''}${city!=null? city+', ':''}${zipCode!=null? zipCode:''}';
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
    final response = await locator<ApiMapService>().getAutoComplete(
        input: input, lang: lang, apiKey: apiKey, sessionToken: sessionToken);
    if (response.statusCode == 200) {
      final result = response.body;
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
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
    final place = Place();
    GoogleMapsPlaces _places =
        new GoogleMapsPlaces(apiKey: apiKey); //Same API_KEY as above
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(placeId);
    double latitude = detail.result.geometry.location.lat;
    double longitude = detail.result.geometry.location.lng;
    var components = detail.result.addressComponents;
    place.name = detail.result.name;
    components.forEach((AddressComponent c) {
      print(c.toJson());
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
  CSPosition location;
  CSPosition originalLocation;

  LocationSearchResult(double latitude, double longitude,
      {this.locationDetails}) {
    this.location =  CSPosition.fromMap({"latitude":latitude, "longitude":longitude});
    this.originalLocation =  CSPosition.fromMap({"latitude":latitude, "longitude":longitude});
  }

  toJson() {
    return "${location.latitude} ${location.longitude} ${locationDetails.toString()}";
  }
}
