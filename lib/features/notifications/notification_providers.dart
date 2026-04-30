import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/logs/application/fuel_log_providers.dart';
import 'package:fuelkeeper/features/notifications/local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 설정한 "주유 후 N일 경과 시 알림" 사용 여부.
class NotificationEnabledNotifier extends Notifier<bool> {
  static const _prefsKey = 'notification.fuelReminderEnabled';

  @override
  bool build() {
    _restore();
    return false;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {}
  }

  Future<void> set(bool value) async {
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (_) {}
  }
}

final notificationEnabledProvider =
    NotifierProvider<NotificationEnabledNotifier, bool>(
  NotificationEnabledNotifier.new,
);

/// 알림 주기(일). 기본 14일.
class NotificationPeriodNotifier extends Notifier<int> {
  static const _prefsKey = 'notification.fuelReminderDays';
  static const defaultDays = 14;
  static const options = <int>[7, 14, 21, 30];

  @override
  int build() {
    _restore();
    return defaultDays;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getInt(_prefsKey);
      if (raw != null && options.contains(raw)) state = raw;
    } catch (_) {}
  }

  Future<void> set(int value) async {
    if (!options.contains(value)) return;
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, value);
    } catch (_) {}
  }
}

final notificationPeriodProvider =
    NotifierProvider<NotificationPeriodNotifier, int>(
  NotificationPeriodNotifier.new,
);

/// 알림 ON/OFF·주기와 마지막 주유 일자가 바뀔 때마다
/// 자동으로 OS 스케줄을 재예약한다. 별도 위젯 없이도 동작하도록
/// 앱 루트에서 watch 한다.
final fuelReminderSchedulerProvider = Provider<void>((ref) {
  final enabled = ref.watch(notificationEnabledProvider);
  final days = ref.watch(notificationPeriodProvider);
  final logs = ref.watch(allFuelLogsProvider).value ?? const [];

  () async {
    if (!enabled) {
      await LocalNotifications.instance.cancelAll();
      return;
    }
    if (logs.isEmpty) {
      await LocalNotifications.instance.cancelAll();
      return;
    }

    final lastDate = logs
        .map((l) => l.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    await LocalNotifications.instance
        .scheduleFuelReminder(lastFuelDate: lastDate, days: days);
  }();
});
