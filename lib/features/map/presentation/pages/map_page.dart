import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';
import 'package:fuelkeeper/app/theme/app_radius.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/app/theme/app_typography.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:go_router/go_router.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  NaverMapController? _controller;
  Station? _selected;

  static const _initialTarget = NLatLng(37.5009, 127.0364);

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (stations) {
          return Stack(
            children: [
              NaverMap(
                options: const NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: _initialTarget,
                    zoom: 14,
                  ),
                  mapType: NMapType.basic,
                  activeLayerGroups: [NLayerGroup.building],
                  locationButtonEnable: false,
                  rotationGesturesEnable: false,
                  tiltGesturesEnable: false,
                  logoAlign: NLogoAlign.leftBottom,
                  logoMargin: EdgeInsets.only(left: 12, bottom: 24),
                ),
                onMapReady: (controller) async {
                  _controller = controller;
                  await _addMarkers(controller, stations, fuelType);
                },
              ),
              SafeArea(child: _TopBar(fuelType: fuelType)),
              if (_selected != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _StationCard(
                    station: _selected!,
                    fuelType: fuelType,
                    onClose: () => setState(() => _selected = null),
                    onTap: () => context.push(
                      AppRoutes.stationDetail(_selected!.id),
                    ),
                  ),
                ),
              Positioned(
                right: AppSpacing.lg,
                bottom: _selected == null
                    ? AppSpacing.lg
                    : AppSpacing.lg + 180,
                child: _MyLocationButton(
                  onPressed: () => _controller?.updateCamera(
                    NCameraUpdate.scrollAndZoomTo(
                      target: _initialTarget,
                      zoom: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addMarkers(
    NaverMapController controller,
    List<Station> stations,
    FuelType fuelType,
  ) async {
    final markers = <NMarker>{};
    for (final s in stations) {
      final price = s.priceOf(fuelType);
      if (price == null) continue;
      final marker = NMarker(
        id: s.id,
        position: NLatLng(s.latitude, s.longitude),
        caption: NOverlayCaption(
          text: '${(price / 1).round()}원',
          textSize: 11,
          color: Colors.white,
          haloColor: s.brand.color,
        ),
        size: const NSize(28, 36),
      )..setOnTapListener((_) {
          setState(() => _selected = s);
          controller.updateCamera(
            NCameraUpdate.scrollAndZoomTo(
              target: NLatLng(s.latitude, s.longitude),
              zoom: 15.5,
            ),
          );
          return true;
        });
      markers.add(marker);
    }
    await controller.addOverlayAll(markers);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.fuelType});
  final FuelType fuelType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_gas_station_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  fuelType.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  const _MyLocationButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.my_location_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({
    required this.station,
    required this.fuelType,
    required this.onClose,
    required this.onTap,
  });

  final Station station;
  final FuelType fuelType;
  final VoidCallback onClose;
  final VoidCallback onTap;

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buf.write(s[i]);
      final remain = s.length - i - 1;
      if (remain > 0 && remain % 3 == 0) buf.write(',');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final price = station.priceOf(fuelType);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Material(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: station.brand.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${station.brand.label} · ${station.distanceKm.toStringAsFixed(1)}km',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  if (price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_fmt(price)}원',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          fuelType.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
