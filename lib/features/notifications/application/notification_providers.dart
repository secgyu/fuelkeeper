import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/notifications/data/notification_repository.dart';
import 'package:fuelkeeper/features/notifications/domain/notification_item.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(),
);

final notificationsProvider = FutureProvider<List<NotificationItem>>((
  ref,
) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.fetchAll();
});
