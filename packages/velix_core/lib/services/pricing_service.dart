/// Mirror of the backend's calculateBookingPricing() (backend/src/modules/bookings/
/// booking.service.ts). The server recomputes and charges its own figures when the booking is
/// created; this exists only so the summary screen can show the exact same numbers beforehand.
/// Keep the constants in sync with that file.
class PricingBreakdown {
  final double baseRatePerDay;
  final int days;
  final double subtotal;
  final double serviceFee;
  final double vat;
  final double grandTotal;
  final double securityDeposit;

  PricingBreakdown({
    required this.baseRatePerDay,
    required this.days,
    required this.subtotal,
    required this.serviceFee,
    required this.vat,
    required this.grandTotal,
    required this.securityDeposit,
  });

  double get baseRental => subtotal;

  // The backend has no paid add-ons or promo codes; these stay 0 so nothing un-chargeable is shown.
  double get chauffeurTotal => 0;
  double get childSeatTotal => 0;
  double get discount => 0;
}

class PricingService {
  static const double serviceFeeRate = 0.10; // SERVICE_FEE_RATE
  static const double vatRate = 0.075; // VAT_RATE, applied to (subtotal + fee)
  static const double depositRate = 0.20; // DEPOSIT_RATE, a refundable hold on top of the total

  static double _round2(double value) => (value * 100).roundToDouble() / 100;

  static PricingBreakdown calculatePrice({
    required double baseRatePerDay,
    required DateTime pickupDate,
    required DateTime returnDate,
  }) {
    // Any part of a day counts as a full day, minimum 1 -- same as the server.
    final hours = returnDate.difference(pickupDate).inMilliseconds / 86400000;
    final days = hours <= 0 ? 1 : hours.ceil();
    final subtotal = _round2(days * baseRatePerDay);
    final fee = _round2(subtotal * serviceFeeRate);
    final vat = _round2((subtotal + fee) * vatRate);
    final total = _round2(subtotal + fee + vat);
    return PricingBreakdown(
      baseRatePerDay: baseRatePerDay,
      days: days,
      subtotal: subtotal,
      serviceFee: fee,
      vat: vat,
      grandTotal: total,
      securityDeposit: _round2(total * depositRate),
    );
  }
}
