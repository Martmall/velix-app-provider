import '../../models/chat_model.dart';
import '../../models/dispute_model.dart';
import '../../models/notification_model.dart';
import '../../models/support_ticket_model.dart';
import '../../network/api_client.dart';

/// One reply on a support ticket.
class TicketReply {
  final String id;
  final String senderName;
  final bool isSupportReply;
  final String message;
  final DateTime createdAt;
  TicketReply({
    required this.id,
    required this.senderName,
    required this.isSupportReply,
    required this.message,
    required this.createdAt,
  });
}

DateTime _date(dynamic value) => DateTime.tryParse('${value ?? ''}')?.toLocal() ?? DateTime.now();

class SupportRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  // The helpdesk API has no category field, so the category travels as a "[Category] " prefix
  // on the subject and is split back out when reading.
  static final _categoryPrefix = RegExp(r'^\[([^\]]+)\]\s*');

  SupportTicketModel _ticket(Map<String, dynamic> json) {
    final rawSubject = '${json['subject'] ?? ''}';
    final match = _categoryPrefix.firstMatch(rawSubject);
    return SupportTicketModel(
      id: '${json['id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      subject: match != null ? rawSubject.substring(match.end) : rawSubject,
      category: match?.group(1) ?? 'General',
      description: '${json['description'] ?? ''}',
      status: json['status'] == 'closed' ? TicketStatus.closed : TicketStatus.open,
      createdAt: _date(json['created_at']),
      attachmentUrl: json['attachment_url']?.toString(),
    );
  }

  // --- Support tickets (/helpdesk-*) ---

  Future<List<SupportTicketModel>> getTickets() async {
    final response = await _apiClient.get('/helpdesk-list', queryParameters: {'per_page': 100});
    return ApiClient.listFrom(response.data).map(_ticket).toList();
  }

  Future<SupportTicketModel> createTicket({
    required String subject,
    required String category,
    required String description,
    String? attachmentUrl,
  }) async {
    final prefixed = category.isEmpty || category == 'General' ? subject : '[$category] $subject';
    final response = await _apiClient.post('/helpdesk-save', data: {
      'subject': prefixed,
      'description': description,
      'mode': 'app',
      if (attachmentUrl != null && attachmentUrl.startsWith('http')) 'attachment_url': attachmentUrl,
    });
    return _ticket(ApiClient.objectFrom(response.data));
  }

  Future<List<TicketReply>> getTicketReplies(String ticketId) async {
    final response = await _apiClient.get('/helpdesk-detail', queryParameters: {'id': ticketId, 'per_page': 100});
    final activity = response.data is Map ? response.data['activity'] : null;
    return (activity is List ? activity : const [])
        .whereType<Map>()
        .map((json) => TicketReply(
              id: '${json['id']}',
              senderName: '${json['sender_name'] ?? ''}',
              isSupportReply: json['is_support_reply'] == true,
              message: '${json['messages'] ?? ''}',
              createdAt: _date(json['created_at']),
            ))
        .toList();
  }

  Future<void> replyToTicket(String ticketId, String message) async {
    await _apiClient.post('/helpdesk-activity-save/$ticketId', data: {'description': message});
  }

  Future<void> closeTicket(String ticketId) async {
    await _apiClient.post('/helpdesk-closed/$ticketId');
  }

  // --- Disputes ---

  DisputeModel _dispute(Map<String, dynamic> json) {
    return DisputeModel(
      id: '${json['id'] ?? ''}',
      partnerId: '${json['againstId'] ?? ''}',
      bookingId: '${json['bookingId'] ?? ''}',
      carName: '',
      reason: '${json['reason'] ?? ''}',
      description: '${json['description'] ?? ''}',
      claimAmount: 0,
      status: switch ('${json['status']}') {
        'UNDER_REVIEW' => DisputeStatus.underReview,
        'RESOLVED' => DisputeStatus.resolved,
        'DISMISSED' => DisputeStatus.rejected,
        _ => DisputeStatus.pending,
      },
      createdAt: _date(json['createdAt']),
    );
  }

  /// Disputes the caller raised or that were raised against them.
  Future<List<DisputeModel>> getDisputes() async {
    final response = await _apiClient.get('/disputes', queryParameters: {'per_page': 100});
    return ApiClient.listFrom(response.data).map(_dispute).toList();
  }

  Future<DisputeModel> createDispute({
    required String bookingId,
    required String reason,
    required String description,
  }) async {
    final response = await _apiClient.post('/bookings/$bookingId/disputes', data: {
      'reason': reason,
      if (description.trim().isNotEmpty) 'description': description.trim(),
    });
    return _dispute(ApiClient.objectFrom(response.data));
  }

  // --- Reviews ---

  /// Only allowed once per completed booking, by its customer.
  Future<void> submitReview({required String bookingId, required int rating, String? comment}) async {
    await _apiClient.post('/bookings/$bookingId/reviews', data: {
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
  }

  // --- Notifications ---

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/notifications', queryParameters: {'per_page': 100});
    return ApiClient.listFrom(response.data)
        .map((json) => NotificationModel(
              id: '${json['id'] ?? ''}',
              recipientId: '',
              title: '${json['title'] ?? ''}',
              message: '${json['body'] ?? ''}',
              timestamp: _date(json['createdAt']),
              isRead: json['isRead'] == true,
              bookingId: json['relatedBookingId']?.toString(),
            ))
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  /// The API marks one at a time; there is no bulk endpoint.
  Future<void> markAllNotificationsRead(Iterable<String> unreadIds) async {
    await Future.wait(unreadIds.map(markNotificationRead));
  }

  // --- Support chat (a message thread with no booking, answered from the admin inbox) ---

  Future<Map<String, dynamic>?> _supportThread() async {
    final response = await _apiClient.get('/message-threads');
    final threads = ApiClient.listFrom(response.data);
    for (final thread in threads) {
      if (thread['booking_id'] == null && thread['closed'] != true) return thread;
    }
    return null;
  }

  Future<List<ChatMessageModel>> getChatMessages({required String currentUserId}) async {
    final thread = await _supportThread();
    if (thread == null) return [];
    final threadId = '${thread['id']}';
    final response = await _apiClient.get('/message-thread-detail', queryParameters: {'threadId': threadId});
    final messages = response.data is Map ? response.data['messages'] : null;
    // Opening the conversation counts as reading it.
    await _apiClient.post('/message-thread-read', data: {'threadId': threadId});
    return (messages is List ? messages : const []).whereType<Map>().map((json) {
      final mine = json['sender_user_id'] == currentUserId;
      return ChatMessageModel(
        id: '${json['id']}',
        conversationId: threadId,
        senderId: '${json['sender_user_id'] ?? ''}',
        senderName: mine ? 'You' : 'Velix Support',
        text: '${json['body'] ?? ''}',
        timestamp: _date(json['created_at']),
        isUser: mine,
      );
    }).toList();
  }

  /// Sends to the user's open support conversation, starting one if needed.
  Future<void> sendChatMessage(String text) async {
    final thread = await _supportThread();
    if (thread == null) {
      await _apiClient.post('/message-thread-start', data: {'subject': 'Support', 'body': text});
    } else {
      await _apiClient.post('/message-send', data: {'threadId': '${thread['id']}', 'body': text});
    }
  }
}
