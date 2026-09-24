class PricingBreakdown {
  final double baseRatePerDay;
  final int days;
  final double subtotal;
  final double mandatoryInsurancePerDay;
  final double mandatoryInsuranceTotal;
  final double optionalAddOnsTotal;
  final double addOnsTotal;
  final double serviceFee;
  final double discountAmount;
  final double grandTotal;

  PricingBreakdown({
    required this.baseRatePerDay,
    required this.days,
    required this.subtotal,
    this.mandatoryInsurancePerDay = 5000.0,
    double? mandatoryInsuranceTotal,
    double? optionalAddOnsTotal,
    required this.addOnsTotal,
    required this.serviceFee,
    required this.discountAmount,
    required this.grandTotal,
  })  : mandatoryInsuranceTotal = mandatoryInsuranceTotal ?? (5000.0 * days),
        optionalAddOnsTotal = optionalAddOnsTotal ?? (addOnsTotal - (mandatoryInsuranceTotal ?? (5000.0 * days))).clamp(0.0, double.infinity);

  double get baseRental => subtotal;
  double get chauffeurTotal => optionalAddOnsTotal;
  double get childSeatTotal => 0.0;
  double get vat => serviceFee;
  double get discount => discountAmount;
  double get securityDeposit => 50000.0;
}

class PricingService {
  static PricingBreakdown calculatePrice({
    required double baseRatePerDay,
    required DateTime pickupDate,
    required DateTime returnDate,
    List<double> selectedAddOnPrices = const [],
    double mandatoryInsurancePerDay = 5000.0,
    String? promoCode,
  }) {
    int days = returnDate.difference(pickupDate).inDays;
    if (days <= 0) days = 1;

    final double subtotal = baseRatePerDay * days;
    final double mandatoryInsuranceTotal = mandatoryInsurancePerDay * days;

    double optionalDailyTotal = 0;
    for (var price in selectedAddOnPrices) {
      optionalDailyTotal += price;
    }
    final double optionalAddOnsTotal = optionalDailyTotal * days;
    final double addOnsTotal = mandatoryInsuranceTotal + optionalAddOnsTotal;
    final double serviceFee = (subtotal + addOnsTotal) * 0.05;

    double discountAmount = 0;
    if (promoCode != null) {
      final code = promoCode.trim().toUpperCase();
      if (code == 'VELO5K') {
        discountAmount = 5000;
      } else if (code == 'VELIX10') {
        discountAmount = (subtotal + addOnsTotal) * 0.10;
      }
    }

    final double totalBeforeDiscount = subtotal + addOnsTotal + serviceFee;
    final double grandTotal = (totalBeforeDiscount - discountAmount).clamp(0.0, double.infinity);

    return PricingBreakdown(
      baseRatePerDay: baseRatePerDay,
      days: days,
      subtotal: subtotal,
      mandatoryInsurancePerDay: mandatoryInsurancePerDay,
      mandatoryInsuranceTotal: mandatoryInsuranceTotal,
      optionalAddOnsTotal: optionalAddOnsTotal,
      addOnsTotal: addOnsTotal,
      serviceFee: serviceFee,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
    );
  }
}

