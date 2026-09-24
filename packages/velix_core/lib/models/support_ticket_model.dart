enum TicketStatus { open, inProgress, resolved, closed }

class SupportTicketModel {
  final String id;
  final String userId;
  final String subject;
  final String category;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;
  final String? attachmentUrl;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.attachmentUrl,
  });
}
