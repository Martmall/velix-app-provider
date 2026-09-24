class NotificationModel {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final String? bookingId;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.bookingId,
  });

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      recipientId: recipientId,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute,
      bookingId: bookingId,
    );
  }
}
