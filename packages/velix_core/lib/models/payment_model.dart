enum PaymentMethodType { card, bank, wallet }

enum PaymentStatus { pending, processing, completed, failed, refunded }

class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final PaymentMethodType method;
  final PaymentStatus status;
  final DateTime timestamp;
  final String? reference;
  final String? cardLast4;
  final String? bankName;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.timestamp,
    this.reference,
    this.cardLast4,
    this.bankName,
  });
}

class WalletTransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isCredit;
  final DateTime timestamp;
  final String reference;
  final String status;

  WalletTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.timestamp,
    required this.reference,
    this.status = 'Completed',
  });
}

