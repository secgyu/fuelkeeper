import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/core/location/kakao_local_repository.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

const LatLng _fallbackLocation = LatLng(37.4979, 127.0276);
const String _fallbackAddress = '강남구 역삼동';

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

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.medium,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 12),
        ),
      );
      if (_isWithinKorea(position.latitude, position.longitude)) {
        return LatLng(position.latitude, position.longitude);
      }
    } catch (_) {}

    final last = await Geolocator.getLastKnownPosition();
    if (last != null && _isWithinKorea(last.latitude, last.longitude)) {
      return LatLng(last.latitude, last.longitude);
    }

    return _fallbackLocation;
  } catch (_) {
    return _fallbackLocation;
  }
});

final kakaoLocalRepositoryProvider = Provider<KakaoLocalRepository>(
  (ref) => KakaoLocalRepository(),
);

final currentAddressProvider = FutureProvider<String>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final kakao = ref.read(kakaoLocalRepositoryProvider);
  final kakaoResult = await kakao.reverseGeocode(location);
  if (kakaoResult != null && kakaoResult.isNotEmpty) {
    return kakaoResult;
  }

  try {
    await setLocaleIdentifier('ko_KR');
    final placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );
    if (placemarks.isNotEmpty) {
      final formatted = _formatKoreanAddress(placemarks.first);
      if (formatted != null) return formatted;
    }
  } catch (_) {}

  return _fallbackAddress;
});

final RegExp _provincePattern = RegExp(r'(특별시|광역시|특별자치시|특별자치도|도)$');
final RegExp _districtPattern = RegExp(r'[가-힣A-Za-z0-9]+(시|군|구)$');
final RegExp _neighborhoodPattern = RegExp(r'[가-힣A-Za-z0-9]+(읍|면|동|리)$');

String? _formatKoreanAddress(Placemark p) {
  final candidates = <String>{
    for (final v in [
      p.administrativeArea,
      p.subAdministrativeArea,
      p.locality,
      p.subLocality,
      p.thoroughfare,
      p.name,
    ])
      if (v != null && v.trim().isNotEmpty) v.trim(),
  };

  final districts = <String>{};
  final neighborhoods = <String>{};

  for (final v in candidates) {
    if (_provincePattern.hasMatch(v)) continue;
    if (_districtPattern.hasMatch(v)) {
      districts.add(v);
    } else if (_neighborhoodPattern.hasMatch(v)) {
      neighborhoods.add(v);
    }
  }

  final district =
      districts
          .firstWhere(
            (s) => s.endsWith('구') || s.endsWith('군'),
            orElse: () => '',
          )
          .isNotEmpty
      ? districts.firstWhere((s) => s.endsWith('구') || s.endsWith('군'))
      : districts.firstWhere((s) => s.endsWith('시'), orElse: () => '');

  String? neighborhood;
  if (neighborhoods.isNotEmpty) {
    final sorted = neighborhoods.toList()
      ..sort((a, b) => a.length.compareTo(b.length));
    neighborhood = sorted.first;
  }

  if (district.isEmpty && neighborhood == null) return null;
  if (district.isEmpty) return neighborhood;
  if (neighborhood == null || neighborhood == district) return district;
  return '$district $neighborhood';
}
