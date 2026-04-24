import 'package:proj4dart/proj4dart.dart';

class LatLng {
  const LatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class KatecPoint {
  const KatecPoint(this.x, this.y);
  final double x;
  final double y;
}

class CoordinateConverter {
  CoordinateConverter._();

  static final _wgs84 = Projection.WGS84;
  static final _katec = Projection.add(
    'KATEC',
    '+proj=tmerc +lat_0=38 +lon_0=128 +k=0.9999 '
    '+x_0=400000 +y_0=600000 +ellps=bessel +units=m +no_defs',
  );

  static KatecPoint wgs84ToKatec(double lat, double lng) {
    final point = Point(x: lng, y: lat);
    final result = _wgs84.transform(_katec, point);
    return KatecPoint(result.x, result.y);
  }

  static LatLng katecToWgs84(double x, double y) {
    final point = Point(x: x, y: y);
    final result = _katec.transform(_wgs84, point);
    return LatLng(result.y, result.x);
  }
}
