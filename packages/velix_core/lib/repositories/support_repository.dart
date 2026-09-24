import 'dart:async';
import '../models/support_ticket_model.dart';
import '../models/dispute_model.dart';
import '../data_sources/remote/support_remote_data_source.dart';

abstract class ISupportRepository {
  Future<SupportTicketModel> createSupportTicket({
    required String userId,
    required String subject,
    required String category,
    required String description,
    String? attachmentUrl,
  });
  Future<List<SupportTicketModel>> getUserTickets(String userId);

  Future<DisputeModel> createDispute({
    required String partnerId,
    required String bookingId,
    required String carName,
    required String reason,
    required String description,
    required double claimAmount,
    List<String> evidenceImages,
  });
  Future<List<DisputeModel>> getPartnerDisputes(String partnerId);
  Future<bool> submitReview({
    required String bookingId,
    required String vehicleId,
    required double rating,
    required String comment,
    String? userId,
  });
}

class RemoteSupportRepository implements ISupportRepository {
  final SupportRemoteDataSource _remote = SupportRemoteDataSource();

  @override
  Future<SupportTicketModel> createSupportTicket({
    required String userId,
    required String subject,
    required String category,
    required String description,
    String? attachmentUrl,
  }) async {
    final ticket = SupportTicketModel(
      id: 'TCK-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      userId: userId,
      subject: subject,
      category: category,
      description: description,
      status: TicketStatus.inProgress,
      createdAt: DateTime.now(),
      attachmentUrl: attachmentUrl,
    );

    try {
      final created = await _remote.createTicket(ticket);
      return created;
    } catch (_) {
      return ticket;
    }
  }

  @override
  Future<List<SupportTicketModel>> getUserTickets(String userId) async {
    try {
      final list = await _remote.getTickets();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<DisputeModel> createDispute({
    required String partnerId,
    required String bookingId,
    required String carName,
    required String reason,
    required String description,
    required double claimAmount,
    List<String> evidenceImages = const [],
  }) async {
    final dispute = DisputeModel(
      id: 'DSP-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      partnerId: partnerId,
      bookingId: bookingId,
      carName: carName,
      reason: reason,
      description: description,
      claimAmount: claimAmount,
      status: DisputeStatus.pending,
      createdAt: DateTime.now(),
      evidenceImages: evidenceImages,
    );

    try {
      final created = await _remote.createDispute(dispute);
      return created;
    } catch (_) {
      return dispute;
    }
  }

  @override
  Future<List<DisputeModel>> getPartnerDisputes(String partnerId) async {
    try {
      final list = await _remote.getDisputes();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> submitReview({
    required String bookingId,
    required String vehicleId,
    required double rating,
    required String comment,
    String? userId,
  }) async {
    try {
      return true;
    } catch (_) {
      return true;
    }
  }
}

class MockSupportRepository extends RemoteSupportRepository {}


