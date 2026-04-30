import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/core/location/presentation/location_override_banner.dart';
import 'package:fuelkeeper/core/location/presentation/location_permission_dialog.dart';
import 'package:fuelkeeper/core/location/presentation/location_status_banner.dart';
import 'package:fuelkeeper/core/widgets/error_view.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/fuel_type_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/home_skeleton.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/price_banner.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/radius_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/sort_filter_row.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/station_list_tile.dart';
import 'package:fuelkeeper/features/home/presentation/widgets/top_station_card.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshing = false;

  Future<void> _refreshLocation() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      ref.read(stationRepositoryProvider).clearCache();
      ref.invalidate(currentLocationProvider);
      ref.invalidate(currentAddressProvider);
      ref.invalidate(stationsProvider);
      ref.invalidate(nationalAveragesProvider);
      await ref.read(stationsProvider.future);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('최신 정보로 업데이트했어요'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (e) {
      debugPrint('[home] refresh failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('새로고침에 실패했어요. 잠시 후 다시 시도해주세요.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncStations = ref.watch(filteredStationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final national = ref.watch(nationalAverageProvider);
    final asyncAddress = ref.watch(currentAddressProvider);

    // 위치 권한이 영구 거부 또는 시스템 OFF면 세션당 한 번 다이얼로그로 강력 안내한다.
    ref.listen(locationResultProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          final shouldShow = result.status == LocationStatus.deniedForever ||
              result.status == LocationStatus.serviceDisabled;
          if (!shouldShow) return;
          if (ref.read(locationDialogShownProvider)) return;
          ref.read(locationDialogShownProvider.notifier).markShown();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showLocationPermissionDialog(context, status: result.status);
          });
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.base,
        title: InkWell(
          onTap: _refreshLocation,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  asyncAddress.maybeWhen(data: (a) => a, orElse: () => '내 위치'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                _RefreshIcon(isRefreshing: _isRefreshing),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: '검색',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshLocation,
          child: asyncStations.when(
            loading: () => const HomeSkeleton(),
            error: (e, st) {
              debugPrint('[home] stations load failed: $e\n$st');
              return ErrorView(
                title: '주유소 정보를 불러오지 못했어요',
                message: '인터넷 연결을 확인하고\n잠시 후 다시 시도해주세요.',
                icon: Icons.cloud_off_rounded,
                onRetry: _refreshLocation,
              );
            },
            data: (stations) {
              if (stations.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    AppSpacing.sm,
                    AppSpacing.base,
                    AppSpacing.xxl,
                  ),
                  children: const [
                    LocationOverrideBanner(),
                    LocationStatusBanner(),
                    PriceBanner(),
                    SizedBox(height: AppSpacing.base),
                    FuelTypeFilterRow(),
                    SizedBox(height: AppSpacing.xxl),
                    _EmptyState(),
                  ],
                );
              }
              return _StationListView(
                stations: stations,
                fuelType: fuelType,
                referencePrice: national,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RefreshIcon extends StatefulWidget {
  const _RefreshIcon({required this.isRefreshing});

  final bool isRefreshing;

  @override
  State<_RefreshIcon> createState() => _RefreshIconState();
}

class _RefreshIconState extends State<_RefreshIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _RefreshIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.refresh_rounded,
        size: 18,
        color: widget.isRefreshing
            ? context.colors.primary
            : context.colors.textSecondary,
      ),
    );
  }
}

class _StationListView extends StatelessWidget {
  const _StationListView({
    required this.stations,
    required this.fuelType,
    required this.referencePrice,
  });

  final List<Station> stations;
  final dynamic fuelType;
  final int? referencePrice;

  @override
  Widget build(BuildContext context) {
    final lowest = stations
        .map((s) => s.priceOf(fuelType)!)
        .reduce((a, b) => a < b ? a : b);
    final top = stations.first;
    final rest = stations.skip(1).toList();

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xxl,
      ),
      itemCount: rest.length + 7,
      separatorBuilder: (context, i) {
        if (i <= 5) {
          return const SizedBox(height: AppSpacing.base);
        }
        return const SizedBox(height: AppSpacing.sm);
      },
      itemBuilder: (context, i) {
        if (i == 0) return const LocationOverrideBanner();
        if (i == 1) return const LocationStatusBanner();
        if (i == 2) return const PriceBanner();
        if (i == 3) return const FuelTypeFilterRow();
        if (i == 4) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '검색 반경',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: RadiusFilterRow()),
            ],
          );
        }
        if (i == 5) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '주변 ${stations.length}곳',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SortFilterRow(),
            ],
          );
        }
        if (i == 6) {
          return TopStationCard(
            station: top,
            fuelType: fuelType,
            referencePrice: referencePrice,
            onTap: () => context.push(AppRoutes.stationDetail(top.id)),
          );
        }
        final station = rest[i - 7];
        return StationListTile(
          rank: i - 5,
          station: station,
          fuelType: fuelType,
          lowestPrice: lowest,
          onTap: () => context.push(AppRoutes.stationDetail(station.id)),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: context.colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('주변 주유소가 없어요', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '다른 연료 종류로 변경해보세요',
              style: AppTypography.body2.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

