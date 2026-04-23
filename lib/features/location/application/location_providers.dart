import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuelkeeper/features/location/domain/region.dart';

class SelectedRegion extends Notifier<Region> {
  @override
  Region build() => kMockRegions.first;

  void set(Region region) => state = region;
}

final selectedRegionProvider = NotifierProvider<SelectedRegion, Region>(
  SelectedRegion.new,
);
