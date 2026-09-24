enum DisputeStatus { pending, underReview, resolved, rejected }

class DisputeModel {
  final String id;
  final String partnerId;
  final String bookingId;
  final String carName;
  final String reason;
  final String description;
  final double claimAmount;
  final DisputeStatus status;
  final DateTime createdAt;
  final List<String> evidenceImages;

  DisputeModel({
    required this.id,
    required this.partnerId,
    required this.bookingId,
    required this.carName,
    required this.reason,
    required this.description,
    required this.claimAmount,
    required this.status,
    required this.createdAt,
    this.evidenceImages = const [],
  });
}
