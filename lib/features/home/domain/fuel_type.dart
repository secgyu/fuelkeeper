enum FuelType {
  gasoline('휘발유'),
  premiumGasoline('고급휘발유'),
  diesel('경유'),
  lpg('LPG');

  const FuelType(this.label);
  final String label;
}
