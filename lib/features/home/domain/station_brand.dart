import 'package:flutter/material.dart';
import 'package:fuelkeeper/app/theme/app_colors.dart';

enum StationBrand {
  sk('SK엔크린', AppColors.brandSk),
  gs('GS칼텍스', AppColors.brandGs),
  hyundai('현대오일뱅크', AppColors.brandHyundai),
  sOil('S-OIL', AppColors.brandSOil),
  economy('알뜰주유소', AppColors.brandEconomy);

  const StationBrand(this.label, this.color);
  final String label;
  final Color color;
}
