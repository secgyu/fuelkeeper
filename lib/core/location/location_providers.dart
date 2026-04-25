import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';
import 'package:geolocator/geolocator.dart';

const LatLng _fallbackLocation = LatLng(37.4979, 127.0276);

bool _isWithinKorea(double lat, double lng) {
  return lat >= 33.0 && lat <= 38.7 && lng >= 124.5 && lng <= 132.0;
}

final currentLocationProvider = FutureProvider<LatLng>((ref) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _fallbackLocation;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _fallbackLocation;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 6),
      ),
    );
    if (!_isWithinKorea(position.latitude, position.longitude)) {
      return _fallbackLocation;
    }
    return LatLng(position.latitude, position.longitude);
  } catch (_) {
    return _fallbackLocation;
  }
});
