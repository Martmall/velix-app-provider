import '../../models/support_ticket_model.dart';
import '../../models/dispute_model.dart';
import '../../models/notification_model.dart';
import '../../models/chat_model.dart';
import '../../network/api_client.dart';

class SupportRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<List<SupportTicketModel>> getTickets() async {
    final response = await _apiClient.get('/support/tickets');
    final List list = response.data['data'] ?? [];
    return list.map((json) => SupportTicketModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? 'usr_101',
      subject: json['subject'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      status: TicketStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] ?? '').toString().toLowerCase().replaceAll('_', ''),
        orElse: () => TicketStatus.open,
      ),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
    )).toList();
  }

  Future<SupportTicketModel> createTicket(SupportTicketModel ticket) async {
    final response = await _apiClient.post('/support/tickets', data: {
      'subject': ticket.subject,
      'category': ticket.category,
      'description': ticket.description,
      'attachmentUrl': ticket.attachmentUrl,
    });
    final json = response.data['data'];
    return SupportTicketModel(
      id: json['id'] ?? ticket.id,
      userId: json['userId'] ?? ticket.userId,
      subject: json['subject'] ?? ticket.subject,
      category: json['category'] ?? ticket.category,
      description: json['description'] ?? ticket.description,
      status: TicketStatus.inProgress,
      createdAt: DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Future<List<DisputeModel>> getDisputes() async {
    final response = await _apiClient.get('/partner/disputes');
    final List list = response.data['data'] ?? [];
    return list.map((json) => DisputeModel(
      id: json['id'] ?? '',
      partnerId: json['partnerId'] ?? 'ptr_202',
      bookingId: json['bookingId'] ?? '',
      carName: json['carName'] ?? '',
      reason: json['reason'] ?? 'Vehicle Damage',
      description: json['description'] ?? '',
      claimAmount: (json['claimAmount'] as num?)?.toDouble() ?? 0.0,
      status: DisputeStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == (json['status'] ?? '').toString().toLowerCase().replaceAll('_', ''),
        orElse: () => DisputeStatus.pending,
      ),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      evidenceImages: (json['evidenceImages'] as List?)?.map((e) => e.toString()).toList() ?? [],
    )).toList();
  }

  Future<DisputeModel> createDispute(DisputeModel dispute) async {
    final response = await _apiClient.post('/partner/disputes', data: {
      'bookingId': dispute.bookingId,
      'carName': dispute.carName,
      'reason': dispute.reason,
      'description': dispute.description,
      'claimAmount': dispute.claimAmount,
      'evidenceImages': dispute.evidenceImages,
    });
    final json = response.data['data'];
    return DisputeModel(
      id: json['id'] ?? dispute.id,
      partnerId: json['partnerId'] ?? dispute.partnerId,
      bookingId: json['bookingId'] ?? dispute.bookingId,
      carName: json['carName'] ?? dispute.carName,
      reason: json['reason'] ?? dispute.reason,
      description: json['description'] ?? dispute.description,
      claimAmount: (json['claimAmount'] as num?)?.toDouble() ?? dispute.claimAmount,
      status: DisputeStatus.pending,
      createdAt: DateTime.now(),
      evidenceImages: dispute.evidenceImages,
    );
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/notifications');
    final List list = response.data['data'] ?? [];
    return list.map((json) => NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? 'usr_101',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) ?? DateTime.now() : DateTime.now(),
      isRead: json['isRead'] ?? false,
      bookingId: json['bookingId'],
    )).toList();
  }

  Future<void> markAllNotificationsRead() async {
    await _apiClient.patch('/notifications/read-all');
  }

  Future<List<ChatMessageModel>> getChatMessages() async {
    final response = await _apiClient.get('/chat/messages');
    final List list = response.data['data'] ?? [];
    return list.map((json) => ChatMessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? 'conv_101_202',
      senderId: json['senderId'] ?? 'usr_101',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) ?? DateTime.now() : DateTime.now(),
      isUser: json['isUser'] ?? true,
    )).toList();
  }

  Future<ChatMessageModel> sendChatMessage(String text, bool isUser) async {
    final response = await _apiClient.post('/chat/messages', data: {
      'text': text,
      'isUser': isUser,
    });
    final json = response.data['data'];
    return ChatMessageModel(
      id: json['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: json['conversationId'] ?? 'conv_101_202',
      senderId: json['senderId'] ?? 'usr_101',
      senderName: json['senderName'] ?? (isUser ? 'Oluwaseun Temilola' : 'Chief John Adebayo'),
      text: json['text'] ?? text,
      timestamp: DateTime.now(),
      isUser: isUser,
    );
  }
}
