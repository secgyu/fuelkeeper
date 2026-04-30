import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 앱 전역 로컬 알림 헬퍼. iOS·Android에 공통으로 사용된다.
///
/// 푸시 알림(FCM 등)과 달리 백엔드 없이 동작하며, 앱이 강제종료되어 있어도
/// OS 스케줄러가 지정된 시각에 알림을 띄운다.
class LocalNotifications {
  LocalNotifications._();
  static final instance = LocalNotifications._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 앱 시작 시 한 번 호출한다.
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    // OS 로컬 시간대 정보가 없으면 zonedSchedule이 실패하므로 안전하게 fallback.
    try {
      tz.setLocalLocation(tz.getLocation(_systemTimeZoneName()));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings:
          const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  /// 사용자에게 알림 권한을 요청한다. iOS/Android 13+는 명시적 요청 필요.
  Future<bool> requestPermissions() async {
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosOk = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidOk =
        await androidImpl?.requestNotificationsPermission() ?? true;

    return iosOk && androidOk;
  }

  /// 모든 예약된 알림을 취소한다.
  Future<void> cancelAll() => _plugin.cancelAll();

  /// 마지막 주유로부터 [days]일이 경과한 시점의 오전 9시에 알림을 띄운다.
  ///
  /// 동일 ID로 다시 예약하면 이전 예약이 자동으로 대체된다.
  Future<void> scheduleFuelReminder({
    required DateTime lastFuelDate,
    required int days,
  }) async {
    if (!_initialized) await init();

    const id = 1001;
    await _plugin.cancel(id: id);

    final fireAt = DateTime(
      lastFuelDate.year,
      lastFuelDate.month,
      lastFuelDate.day,
      9,
    ).add(Duration(days: days));

    if (!fireAt.isAfter(DateTime.now())) {
      // 이미 지난 시각이면 다음 날 오전 9시로 미룬다.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final adjusted = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
      await _zonedSchedule(id, adjusted, days);
      return;
    }

    await _zonedSchedule(id, fireAt, days);
  }

  Future<void> _zonedSchedule(int id, DateTime fireAt, int days) async {
    final scheduledAt = tz.TZDateTime.from(fireAt, tz.local);
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: '주유한 지 $days일 지났어요',
        body: '주변 최저가 주유소를 확인해보세요.',
        scheduledDate: scheduledAt,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'fuel_reminder',
            '주유 알림',
            channelDescription: '마지막 주유 후 일정 기간 경과 시 알리는 알림입니다.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('[notifications] zonedSchedule failed: $e');
    }
  }

  String _systemTimeZoneName() {
    // FlutterLocalNotifications 공식 예시는 flutter_native_timezone를 권장하지만,
    // 의존성을 더 늘리지 않기 위해 기본값을 'Asia/Seoul'로 두고 init에서 fallback 처리한다.
    return 'Asia/Seoul';
  }
}
