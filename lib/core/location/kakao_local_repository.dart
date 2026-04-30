import 'package:dio/dio.dart';
import 'package:fuelkeeper/app/config/kakao_config.dart';
import 'package:fuelkeeper/core/network/retry_interceptor.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';

class KakaoLocalRepository {
  KakaoLocalRepository({Dio? dio}) : _dio = dio ?? _defaultDio();

  final Dio _dio;

  static Dio _defaultDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    dio.interceptors.add(RetryInterceptor());
    return dio;
  }

  static const String _endpoint =
      'https://dapi.kakao.com/v2/local/geo/coord2regioncode.json';
  static const String _searchEndpoint =
      'https://dapi.kakao.com/v2/local/search/keyword.json';

  /// 키워드로 장소를 검색한다. (주유소·동·역 등 모두 가능)
  ///
  /// [center]가 지정되면 거리 기반 정렬, 없으면 정확도 정렬.
  Future<List<KakaoPlace>> searchPlaces(
    String query, {
    LatLng? center,
    int size = 15,
  }) async {
    if (!KakaoConfig.isConfigured) return const [];
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final params = <String, dynamic>{
        'query': trimmed,
        'size': size,
      };
      if (center != null) {
        params['x'] = center.longitude;
        params['y'] = center.latitude;
        params['sort'] = 'distance';
      } else {
        params['sort'] = 'accuracy';
      }
      final response = await _dio.get<Map<String, dynamic>>(
        _searchEndpoint,
        queryParameters: params,
        options: Options(
          headers: {'Authorization': 'KakaoAK ${KakaoConfig.restApiKey}'},
        ),
      );
      final documents = response.data?['documents'];
      if (documents is! List) return const [];
      return documents
          .whereType<Map>()
          .map((m) => KakaoPlace.fromJson(m.cast<String, dynamic>()))
          .where((p) => p != null)
          .cast<KakaoPlace>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<String?> reverseGeocode(LatLng location) async {
    if (!KakaoConfig.isConfigured) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _endpoint,
        queryParameters: {'x': location.longitude, 'y': location.latitude},
        options: Options(
          headers: {'Authorization': 'KakaoAK ${KakaoConfig.restApiKey}'},
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

/// Kakao Local 키워드 검색 결과 한 건.
class KakaoPlace {
  const KakaoPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.category,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String category;

  /// API 호출 시 좌표를 함께 보낸 경우에만 채워진다. (미터)
  final int? distanceMeters;

  static KakaoPlace? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    final name = (json['place_name'] as String?)?.trim() ?? '';
    if (id.isEmpty || name.isEmpty) return null;

    final x = double.tryParse((json['x'] as String?) ?? '');
    final y = double.tryParse((json['y'] as String?) ?? '');
    if (x == null || y == null) return null;

    final road = (json['road_address_name'] as String?)?.trim() ?? '';
    final address = road.isNotEmpty
        ? road
        : ((json['address_name'] as String?)?.trim() ?? '');

    final category = (json['category_name'] as String?)?.trim() ?? '';
    final distance = int.tryParse((json['distance'] as String?) ?? '');

    return KakaoPlace(
      id: id,
      name: name,
      address: address,
      location: LatLng(y, x),
      category: category,
      distanceMeters: distance,
    );
  }
}
