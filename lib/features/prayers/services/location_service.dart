import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'country': country,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        city: json['city'] as String,
        country: json['country'] as String,
      );

  factory LocationData.defaultLocation() => const LocationData(
        latitude: AppConstants.defaultLatitude,
        longitude: AppConstants.defaultLongitude,
        city: AppConstants.defaultCity,
        country: AppConstants.defaultCountry,
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
    final city = _prefs.getString(AppConstants.keyCity);
    final country = _prefs.getString(AppConstants.keyCountry);

    if (latitude == null || longitude == null) {
      return null;
    }

    return LocationData(
      latitude: latitude,
      longitude: longitude,
      city: city ?? AppConstants.defaultCity,
      country: country ?? AppConstants.defaultCountry,
    );
  }

  /// Save location to SharedPreferences
  Future<void> _saveLocation(LocationData location) async {
    await _prefs.setDouble(AppConstants.keyLatitude, location.latitude);
    await _prefs.setDouble(AppConstants.keyLongitude, location.longitude);
    await _prefs.setString(AppConstants.keyCity, location.city);
    await _prefs.setString(AppConstants.keyCountry, location.country);
  }

  /// Get saved or default location synchronously
  LocationData getSavedOrDefaultLocation() {
    return _getSavedLocation() ?? LocationData.defaultLocation();
  }

  /// Update location manually (for city search feature)
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String city,
    required String country,
  }) async {
    final locationData = LocationData(
      latitude: latitude,
      longitude: longitude,
      city: city,
      country: country,
    );
    await _saveLocation(locationData);
  }
}
