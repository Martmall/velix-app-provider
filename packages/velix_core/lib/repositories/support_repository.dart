import 'dart:async';
import '../models/chat_model.dart';
import '../models/dispute_model.dart';
import '../models/notification_model.dart';
import '../models/support_ticket_model.dart';
import '../data_sources/remote/support_remote_data_source.dart';

abstract class ISupportRepository {
  Future<SupportTicketModel> createSupportTicket({
    required String subject,
    required String category,
    required String description,
    String? attachmentUrl,
  });
  Future<List<SupportTicketModel>> getMyTickets();
  Future<List<TicketReply>> getTicketReplies(String ticketId);
  Future<void> replyToTicket(String ticketId, String message);
  Future<void> closeTicket(String ticketId);

  Future<DisputeModel> createDispute({required String bookingId, required String reason, required String description});
  Future<List<DisputeModel>> getMyDisputes();

  Future<void> submitReview({required String bookingId, required int rating, String? comment});

  Future<List<NotificationModel>> getNotifications();
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead(List<NotificationModel> notifications);

  Future<List<ChatMessageModel>> getSupportChat({required String currentUserId});
  Future<void> sendSupportMessage(String text);
}

class RemoteSupportRepository implements ISupportRepository {
  final SupportRemoteDataSource _remote = SupportRemoteDataSource();

  @override
  Future<SupportTicketModel> createSupportTicket({
    required String subject,
    required String category,
    required String description,
    String? attachmentUrl,
  }) =>
      _remote.createTicket(subject: subject, category: category, description: description, attachmentUrl: attachmentUrl);

  @override
  Future<List<SupportTicketModel>> getMyTickets() => _remote.getTickets();

  @override
  Future<List<TicketReply>> getTicketReplies(String ticketId) => _remote.getTicketReplies(ticketId);

  @override
  Future<void> replyToTicket(String ticketId, String message) => _remote.replyToTicket(ticketId, message);

  @override
  Future<void> closeTicket(String ticketId) => _remote.closeTicket(ticketId);

  @override
  Future<DisputeModel> createDispute({required String bookingId, required String reason, required String description}) =>
      _remote.createDispute(bookingId: bookingId, reason: reason, description: description);

  @override
  Future<List<DisputeModel>> getMyDisputes() => _remote.getDisputes();

  @override
  Future<void> submitReview({required String bookingId, required int rating, String? comment}) =>
      _remote.submitReview(bookingId: bookingId, rating: rating, comment: comment);

  @override
  Future<List<NotificationModel>> getNotifications() => _remote.getNotifications();

  @override
  Future<void> markNotificationRead(String id) => _remote.markNotificationRead(id);

  @override
  Future<void> markAllNotificationsRead(List<NotificationModel> notifications) =>
      _remote.markAllNotificationsRead(notifications.where((n) => !n.isRead).map((n) => n.id));

  @override
  Future<List<ChatMessageModel>> getSupportChat({required String currentUserId}) =>
      _remote.getChatMessages(currentUserId: currentUserId);

  @override
  Future<void> sendSupportMessage(String text) => _remote.sendChatMessage(text);
}
