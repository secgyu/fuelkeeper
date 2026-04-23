import 'package:fuelkeeper/features/notifications/domain/notification_item.dart';

class NotificationRepository {
  Future<List<NotificationItem>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    return [
      NotificationItem(
        id: 'n1',
        kind: NotificationKind.priceDrop,
        title: '강남대로주유소 휘발유 38원 인하',
        body: '1,932원 → 1,894원 / 즐겨찾기 주유소',
        createdAt: now.subtract(const Duration(minutes: 18)),
      ),
      NotificationItem(
        id: 'n2',
        kind: NotificationKind.favorite,
        title: '도곡알뜰주유소가 우리동네 최저가에요',
        body: '휘발유 1,879원 / 0.4km',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: 'n3',
        kind: NotificationKind.priceRise,
        title: '청담S-OIL 경유 12원 인상',
        body: '1,760원 → 1,772원',
        createdAt: now.subtract(const Duration(hours: 7)),
        read: true,
      ),
      NotificationItem(
        id: 'n4',
        kind: NotificationKind.system,
        title: 'FuelKeeper 1.1.0 업데이트 안내',
        body: '주유 로그 자동 인식 기능이 추가됐어요.',
        createdAt: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ];
  }
}
