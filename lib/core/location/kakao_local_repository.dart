import 'package:dio/dio.dart';
import 'package:fuelkeeper/app/config/kakao_config.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';

class KakaoLocalRepository {
  KakaoLocalRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _endpoint =
      'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json';

  Future<String?> reverseGeocode(LatLng location) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {'x': location.longitude, 'y': location.latitude},
        options: Options(
          headers: {'Authorization': 'KakaoAK ${KakaoConfig.restApiKey}'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      final documents = response.data?['documents'];
      if (documents is! List || documents.isEmpty) return null;

      final preferred = documents.cast<Map<String, dynamic>>().firstWhere(
        (e) => e['region_type'] == 'B',
        orElse: () => documents.first as Map<String, dynamic>,
      );

      return _format(preferred);
    } catch (_) {
      return null;
    }
  }

  String? _format(Map<String, dynamic> doc) {
    final r1 = (doc['region_1depth_name'] as String?)?.trim() ?? '';
    final r2 = (doc['region_2depth_name'] as String?)?.trim() ?? '';
    final r3 = (doc['region_3depth_name'] as String?)?.trim() ?? '';

    if (r2.isNotEmpty && r3.isNotEmpty) return '$r2 $r3';
    if (r3.isNotEmpty) return r3;
    if (r2.isNotEmpty) return r2;
    if (r1.isNotEmpty) return r1;
    return null;
  }
}
