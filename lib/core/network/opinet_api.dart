import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fuelkeeper/app/config/opinet_config.dart';

class OpinetApi {
  OpinetApi({Dio? dio}) : _dio = dio ?? _defaultDio();

  final Dio _dio;

  static Dio _defaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://www.opinet.co.kr/api',
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
        queryParameters: {
          'out': 'json',
          'certkey': OpinetConfig.apiKey,
        },
      ),
    );
  }

  Future<List<dynamic>> aroundAll({
    required double katecX,
    required double katecY,
    required int radius,
    required String prodcd,
    int sort = 1,
  }) async {
    final response = await _dio.get(
      '/aroundAll.do',
      queryParameters: {
        'x': katecX.toStringAsFixed(0),
        'y': katecY.toStringAsFixed(0),
        'radius': radius,
        'prodcd': prodcd,
        'sort': sort,
      },
    );
    return _extractOilList(response.data);
  }

  Future<Map<String, dynamic>?> detailById(String id) async {
    final response = await _dio.get(
      '/detailById.do',
      queryParameters: {'id': id},
    );
    final list = _extractOilList(response.data);
    if (list.isEmpty) return null;
    return list.first as Map<String, dynamic>;
  }

  Future<List<dynamic>> avgAllPrice() async {
    final response = await _dio.get('/avgAllPrice.do');
    return _extractOilList(response.data);
  }

  Future<List<dynamic>> avgSidoPrice({required String prodcd}) async {
    final response = await _dio.get(
      '/avgSidoPrice.do',
      queryParameters: {'prodcd': prodcd},
    );
    return _extractOilList(response.data);
  }

  Future<List<dynamic>> lowTop10({
    required String area,
    required String prodcd,
  }) async {
    final response = await _dio.get(
      '/lowTop10.do',
      queryParameters: {'area': area, 'prodcd': prodcd},
    );
    return _extractOilList(response.data);
  }

  static List<dynamic> _extractOilList(dynamic data) {
    final decoded = _ensureMap(data);
    if (decoded == null) return const [];
    final result = decoded['RESULT'];
    if (result is! Map) return const [];
    final oil = result['OIL'];
    if (oil is List) return oil;
    return const [];
  }

  static Map<String, dynamic>? _ensureMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map<String, dynamic>) return parsed;
        if (parsed is Map) return Map<String, dynamic>.from(parsed);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
