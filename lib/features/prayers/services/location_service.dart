import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String name; // City name or location name

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  // Keep backwards compatibility with old city/country format
  String get city => name.split(',').first.trim();
  String get country => name.contains(',') ? name.split(',').last.trim() : '';

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'name': name,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        name: json['name'] as String? ?? '${json['city']}, ${json['country']}',
      );

  factory LocationData.defaultLocation() => const LocationData(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        name: '${AppConstants.defaultCity}, ${AppConstants.defaultCountry}',
      );
}

class LocationService {
  final SharedPreferences _prefs;

  LocationService(this._prefs);

  /// Get current location (returns saved or default location)
  /// Manual location selection - GPS disabled for now
  Future<LocationData> getCurrentLocation() async {
    return _getSavedLocation() ?? LocationData.defaultLocation();
  }

  /// Get saved location from SharedPreferences
  LocationData? _getSavedLocation() {
    final latitude = _prefs.getDouble(AppConstants.keyLatitude);
    final longitude = _prefs.getDouble(AppConstants.keyLongitude);

    // Try new format first (name)
    final name = _prefs.getString(AppConstants.keyLocationName);

    // Fallback to old format (city, country)
    final city = _prefs.getString(AppConstants.keyCity);
    final country = _prefs.getString(AppConstants.keyCountry);

    if (latitude == null || longitude == null) {
      return null;
    }

    return LocationData(
      latitude: latitude,
      longitude: longitude,
      name: name ?? (city != null && country != null
          ? '$city, $country'
          : '${AppConstants.defaultCity}, ${AppConstants.defaultCountry}'),
    );
  }

  /// Save location to SharedPreferences
  Future<void> _saveLocation(LocationData location) async {
    await _prefs.setDouble(AppConstants.keyLatitude, location.latitude);
    await _prefs.setDouble(AppConstants.keyLongitude, location.longitude);
    await _prefs.setString(AppConstants.keyLocationName, location.name);
  }

  /// Get saved or default location synchronously
  LocationData getSavedOrDefaultLocation() {
    return _getSavedLocation() ?? LocationData.defaultLocation();
  }

  /// Update location manually (for city search feature)
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String name,
  }) async {
    final locationData = LocationData(
      latitude: latitude,
      longitude: longitude,
      name: name,
    );
    await _saveLocation(locationData);
  }
}
