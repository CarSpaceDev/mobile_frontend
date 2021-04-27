import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

@immutable
class CSPosition extends Equatable {
  CSPosition({
    this.longitude,
    this.latitude,
    this.timestamp,
    this.accuracy,
    this.altitude,
    this.heading,
    this.floor,
    this.speed,
    this.speedAccuracy,
    this.isMocked,
  });

  @override
  List<Object> get props =>
      [longitude, latitude, timestamp, accuracy, altitude, heading, floor, speed, speed, isMocked];

  /// The latitude of this position in degrees normalized to the interval -90.0
  /// to +90.0 (both inclusive).
  final double latitude;

  /// The longitude of the position in degrees normalized to the interval -180
  /// (exclusive) to +180 (inclusive).
  final double longitude;

  /// The time at which this position was determined.
  final DateTime timestamp;

  /// The altitude of the device in meters.
  ///
  /// The altitude is not available on all devices. In these cases the returned
  /// value is 0.0.
  final double altitude;

  /// The estimated horizontal accuracy of the position in meters.
  ///
  /// The accuracy is not available on all devices. In these cases the value is
  /// 0.0.
  final double accuracy;

  /// The heading in which the device is traveling in degrees.
  ///
  /// The heading is not available on all devices. In these cases the value is
  /// 0.0.
  final double heading;

  /// The floor specifies the floor of the building on which the device is
  /// located.
  ///
  /// The floor property is only available on iOS and only when the information
  /// is available. In all other cases this value will be null.
  final int floor;

  /// The speed at which the devices is traveling in meters per second over
  /// ground.
  ///
  /// The speed is not available on all devices. In these cases the value is
  /// 0.0.
  final double speed;

  /// The estimated speed accuracy of this position, in meters per second.
  ///
  /// The speedAccuracy is not available on all devices. In these cases the
  /// value is 0.0.
  final double speedAccuracy;

  /// Will be true on Android (starting from API lvl 18) when the location came
  /// from the mocked provider.
  ///
  /// On iOS this value will always be false.
  final bool isMocked;

  @override
  bool operator ==(dynamic o) {
    var areEqual = o is CSPosition &&
        o.accuracy == accuracy &&
        o.altitude == altitude &&
        o.heading == heading &&
        o.latitude == latitude &&
        o.longitude == longitude &&
        o.floor == o.floor &&
        o.speed == speed &&
        o.speedAccuracy == speedAccuracy &&
        o.timestamp == timestamp &&
        o.isMocked == isMocked;

    return areEqual;
  }

  @override
  int get hashCode =>
      accuracy.hashCode ^
      altitude.hashCode ^
      heading.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      floor.hashCode ^
      speed.hashCode ^
      speedAccuracy.hashCode ^
      timestamp.hashCode ^
      isMocked.hashCode;

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude';
  }

  /// Converts the supplied [Map] to an instance of the [Position] class.
  static CSPosition fromMap(dynamic message) {
    if (message == null) {
      return null;
    }

    final Map<dynamic, dynamic> positionMap = message;

    if (!positionMap.containsKey('latitude')) {
      throw ArgumentError.value(
          positionMap, 'positionMap', 'The supplied map doesn\'t contain the mandatory key `latitude`.');
    }

    if (!positionMap.containsKey('longitude')) {
      throw ArgumentError.value(
          positionMap, 'positionMap', 'The supplied map doesn\'t contain the mandatory key `longitude`.');
    }

    final timestamp = positionMap['timestamp'] != null
        ? DateTime.fromMillisecondsSinceEpoch(positionMap['timestamp'].toInt(), isUtc: true)
        : null;

    return CSPosition(
      latitude: positionMap['latitude'],
      longitude: positionMap['longitude'],
      timestamp: timestamp,
      altitude: positionMap['altitude'] ?? 0.0,
      accuracy: positionMap['accuracy'] ?? 0.0,
      heading: positionMap['heading'] ?? 0.0,
      floor: positionMap['floor'],
      speed: positionMap['speed'] ?? 0.0,
      speedAccuracy: positionMap['speed_accuracy'] ?? 0.0,
      isMocked: positionMap['is_mocked'] ?? false,
    );
  }

  LatLng toLatLng() => LatLng(latitude,longitude);
  /// Converts the [Position] instance into a [Map] instance that can be
  /// serialized to JSON.
  Map<String, dynamic> toJson() => {
        'longitude': longitude,
        'latitude': latitude,
        'timestamp': timestamp?.millisecondsSinceEpoch,
        'accuracy': accuracy,
        'altitude': altitude,
        'floor': floor,
        'heading': heading,
        'speed': speed,
        'speed_accuracy': speedAccuracy,
        'is_mocked': isMocked,
      };
}

class MapSettings extends Equatable {
  final Set<Marker> markers;
  final String mapStyle;
  final String mapStylePOI;
  final BitmapDescriptor lotIcon;
  final BitmapDescriptor driverIcon;
  final bool showPOI;
  final bool scrollEnabled;
  MapSettings(
      {@required this.markers,
      @required this.mapStylePOI,
      @required this.mapStyle,
      @required this.lotIcon,
      @required this.driverIcon,
      @required this.showPOI,
      @required this.scrollEnabled});
  @override
  List<Object> get props => [markers, mapStyle, mapStylePOI, lotIcon, driverIcon, showPOI, scrollEnabled];

  copyWith({Set<Marker> markers, bool showPOI, bool scrollEnabled}) {
    Set<Marker> m;
    bool sPOI;
    bool scroll;
    m = markers ?? this.markers;
    sPOI = showPOI ?? this.showPOI;
    scroll = scrollEnabled ?? this.scrollEnabled;
    return new MapSettings(
        markers: m,
        showPOI: sPOI,
        scrollEnabled: scroll,
        mapStylePOI: this.mapStylePOI,
        mapStyle: this.mapStyle,
        lotIcon: this.lotIcon,
        driverIcon: this.driverIcon);
  }
}
