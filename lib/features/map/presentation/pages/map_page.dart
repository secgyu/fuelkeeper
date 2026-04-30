import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/app/theme/app_color_tokens.dart';
import 'package:fuelkeeper/app/router/app_router.dart';
import 'package:fuelkeeper/app/theme/app_spacing.dart';
import 'package:fuelkeeper/core/location/location_providers.dart';
import 'package:fuelkeeper/core/utils/coordinate_converter.dart';
import 'package:fuelkeeper/features/home/application/home_providers.dart';
import 'package:fuelkeeper/features/home/domain/fuel_type.dart';
import 'package:fuelkeeper/features/home/domain/station.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/empty_map_card.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/fuel_chip_button.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/fuel_picker_sheet.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/my_location_fab.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/station_preview_card.dart';
import 'package:fuelkeeper/features/map/presentation/widgets/status_banner.dart';
import 'package:go_router/go_router.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  static const _fallbackTarget = NLatLng(37.4979, 127.0276);
  static const _defaultZoom = 14.0;
  static const _selectedZoom = 15.5;

  NaverMapController? _controller;
  Station? _selected;
  NOverlayImage? _myLocationIcon;
  StreamSubscription<CompassEvent>? _compassSubscription;
  LatLng? _lastLocation;
  double _lastHeading = 0;

  @override
  void initState() {
    super.initState();
    final events = FlutterCompass.events;
    if (events != null) {
      _compassSubscription = events.listen(_onCompassEvent);
    }
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _onCompassEvent(CompassEvent event) {
    final heading = event.heading;
    if (heading == null) return;
    _lastHeading = heading;
    final controller = _controller;
    if (controller == null || _lastLocation == null) return;
    controller.getLocationOverlay().setBearing(heading);
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsProvider);
    final fuelType = ref.watch(selectedFuelTypeProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    final initialTarget = locationAsync.maybeWhen(
      data: (loc) => NLatLng(loc.latitude, loc.longitude),
      orElse: () => _fallbackTarget,
    );

    ref.listen<AsyncValue<List<Station>>>(stationsProvider, (prev, next) {
      next.whenData((stations) async {
        final controller = _controller;
        if (controller == null) return;
        await controller.clearOverlays();
        await _addMarkers(controller, stations, fuelType);
        locationAsync.whenData((loc) {
          _updateMyLocationOverlay(controller, loc);
        });
      });
    });

    ref.listen<AsyncValue<LatLng>>(currentLocationProvider, (prev, next) {
      next.whenData((loc) {
        final controller = _controller;
        if (controller == null) return;
        _updateMyLocationOverlay(controller, loc);
      });
    });

    final stations = stationsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => const <Station>[],
    );
    final isLoading = stationsAsync.isLoading;
    final error = stationsAsync.hasError ? stationsAsync.error : null;
    final isEmpty = !isLoading && error == null && stations.isEmpty;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: initialTarget,
                zoom: _defaultZoom,
              ),
              mapType: NMapType.basic,
              activeLayerGroups: const [NLayerGroup.building],
              locationButtonEnable: false,
              rotationGesturesEnable: false,
              tiltGesturesEnable: false,
              logoAlign: NLogoAlign.leftBottom,
              logoMargin: const EdgeInsets.only(left: 12, bottom: 24),
            ),
            // 줌 13 이하(시·구 단위)에서는 인접한 주유소 마커들을 묶어 보여
            // 도심에서의 마커 밀집을 완화한다. 줌 14 이상에서는 개별 가격 마커.
            clusterOptions: NaverMapClusteringOptions(
              enableZoomRange: const NInclusiveRange(0, 13),
              animationDuration: const Duration(milliseconds: 250),
              clusterMarkerBuilder: (info, marker) {
                marker.setSize(const NSize(40, 40));
                marker.setCaption(NOverlayCaption(
                  text: info.size.toString(),
                  textSize: 12,
                  color: Colors.white,
                  haloColor: context.colors.primary,
                ));
              },
            ),
            onMapReady: (controller) async {
              _controller = controller;
              await _ensureMyLocationIcon();
              if (!mounted) return;
              await _addMarkers(controller, stations, fuelType);
              locationAsync.whenData((loc) {
                _updateMyLocationOverlay(controller, loc);
              });
            },
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FuelChipButton(
                  fuelType: fuelType,
                  onTap: () => _openFuelPicker(fuelType),
                ),
                if (isLoading)
                  const StatusBanner(
                    icon: Icons.refresh_rounded,
                    text: '주유소 정보를 불러오는 중...',
                    spinning: true,
                  ),
                if (error != null)
                  StatusBanner(
                    icon: Icons.error_outline_rounded,
                    text: '주유소 정보를 불러오지 못했어요',
                    color: context.colors.danger,
                    actionLabel: '재시도',
                    onAction: () => ref.invalidate(stationsProvider),
                  ),
              ],
            ),
          ),
          if (isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: EmptyMapCard(
                fuelType: fuelType,
                onChangeFuel: () => _openFuelPicker(fuelType),
              ),
            ),
          if (_selected != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StationPreviewCard(
                station: _selected!,
                fuelType: fuelType,
                onClose: () => setState(() => _selected = null),
                onTap: () =>
                    context.push(AppRoutes.stationDetail(_selected!.id)),
              ),
            ),
          Positioned(
            right: AppSpacing.lg,
            bottom: _selected == null
                ? (isEmpty ? AppSpacing.lg + 140 : AppSpacing.lg)
                : AppSpacing.lg + 180,
            child: MyLocationFab(
              onPressed: () => _controller?.updateCamera(
                NCameraUpdate.scrollAndZoomTo(
                  target: initialTarget,
                  zoom: _defaultZoom,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFuelPicker(FuelType current) async {
    final picked = await showFuelPickerSheet(context, current: current);
    if (picked != null) {
      ref.read(selectedFuelTypeProvider.notifier).set(picked);
    }
  }

  Future<void> _addMarkers(
    NaverMapController controller,
    List<Station> stations,
    FuelType fuelType,
  ) async {
    final markers = <NClusterableMarker>{};
    for (final s in stations) {
      final price = s.priceOf(fuelType);
      if (price == null) continue;
      if (!s.hasCoordinates) continue;
      final position = NLatLng(s.latitude!, s.longitude!);
      final marker =
          NClusterableMarker(
            id: s.id,
            position: position,
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
                target: position,
                zoom: _selectedZoom,
              ),
            );
            return true;
          });
      markers.add(marker);
    }
    if (markers.isNotEmpty) {
      await controller.addOverlayAll(markers);
    }
  }

  void _updateMyLocationOverlay(
    NaverMapController controller,
    LatLng location,
  ) {
    _lastLocation = location;
    final overlay = controller.getLocationOverlay();
    overlay.setPosition(NLatLng(location.latitude, location.longitude));
    overlay.setIsVisible(true);
    overlay.setCircleColor(context.colors.brandPrimary.withValues(alpha: 0.18));
    overlay.setCircleOutlineColor(
      context.colors.brandPrimary.withValues(alpha: 0.5),
    );
    overlay.setCircleOutlineWidth(1);
    overlay.setCircleRadius(40);
    overlay.setBearing(_lastHeading);
    final icon = _myLocationIcon;
    if (icon != null) {
      overlay.setIcon(icon);
      overlay.setIconSize(const Size(36, 36));
    }
  }

  Future<void> _ensureMyLocationIcon() async {
    if (_myLocationIcon != null) return;
    if (!mounted) return;
    _myLocationIcon = await NOverlayImage.fromWidget(
      context: context,
      size: const Size(36, 36),
      widget: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.brandPrimary,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.navigation_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
