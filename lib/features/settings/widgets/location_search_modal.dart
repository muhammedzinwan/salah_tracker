import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/constants/colors.dart';

class LocationSearchModal extends ConsumerStatefulWidget {
  const LocationSearchModal({super.key});

  @override
  ConsumerState<LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends ConsumerState<LocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
        _isSearching = false;
        if (locations.isEmpty) {
          _errorMessage = 'No locations found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Could not find location. Try a different search.';
        _searchResults = [];
      });
    }
  }

  Future<String> _getLocationName(Location location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        final country = place.country ?? '';

        if (city.isNotEmpty && country.isNotEmpty) {
          return '$city, $country';
        } else if (city.isNotEmpty) {
          return city;
        } else if (country.isNotEmpty) {
          return country;
        }
      }
      return 'Selected Location';
    } catch (e) {
      return 'Selected Location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.secondaryBackground,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
        middle: const Text('Search Location'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Enter city name...',
                onSubmitted: _searchLocation,
                prefixIcon: const Icon(CupertinoIcons.search),
              ),
            ),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: CupertinoColors.systemRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Loading Indicator
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CupertinoActivityIndicator(),
              ),

            // Search Results
            if (!_isSearching && _searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return FutureBuilder<String>(
                      future: _getLocationName(location),
                      builder: (context, snapshot) {
                        final locationName = snapshot.data ?? 'Loading...';
                        final isLoading = !snapshot.hasData;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(16),
                            onPressed: isLoading
                                ? null
                                : () {
                                    // Return selected location with name
                                    Navigator.of(context).pop({
                                      'latitude': location.latitude,
                                      'longitude': location.longitude,
                                      'name': locationName,
                                    });
                                  },
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.location_fill,
                                  color: isLoading
                                      ? CupertinoColors.systemGrey
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locationName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isLoading
                                              ? CupertinoColors.systemGrey
                                              : CupertinoColors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Lat: ${location.latitude.toStringAsFixed(4)}, Long: ${location.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLoading)
                                  const Icon(
                                    CupertinoIcons.chevron_right,
                                    color: CupertinoColors.systemGrey,
                                    size: 20,
                                  )
                                else
                                  const CupertinoActivityIndicator(),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

            // Empty State
            if (!_isSearching && _searchResults.isEmpty && _errorMessage == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.location,
                        size: 64,
                        color: CupertinoColors.systemGrey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for your city',
                        style: TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.systemGrey.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter a city name and press search',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
