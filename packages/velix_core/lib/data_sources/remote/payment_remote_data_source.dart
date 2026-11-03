import '../../models/payment_model.dart';
import '../../network/api_client.dart';

/// A Flutterwave hosted-checkout session. Open [link] (in-app WebView); Flutterwave then
/// redirects to the web app's callback page with `transaction_id` and `status` query params,
/// which [CheckoutSession.callbackPath] identifies.
class CheckoutSession {
  /// paymentId (booking payments) or walletTransactionId (wallet funding).
  final String id;
  final String reference;
  final String link;
  final String callbackPath;
  CheckoutSession({required this.id, required this.reference, required this.link, required this.callbackPath});
}

/// Result of verifying a checkout with the backend (which re-checks with Flutterwave).
enum PaymentOutcome { paid, pending, failed }

PaymentOutcome _outcome(dynamic status) {
  switch ('$status'.toUpperCase()) {
    case 'PAID':
      return PaymentOutcome.paid;
    case 'FAILED':
    case 'REFUNDED':
      return PaymentOutcome.failed;
    default:
      return PaymentOutcome.pending;
  }
}

class WalletSummary {
  final double balance;
  final String currency;
  WalletSummary({required this.balance, required this.currency});
}

class BankDetails {
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  BankDetails({required this.bankName, required this.bankCode, required this.accountNumber, required this.accountName});
}

class PaymentRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<CheckoutSession> initiateBookingPayment(String bookingId) async {
    final response = await _apiClient.post('/payments/bookings/$bookingId/initiate', data: {});
    final data = ApiClient.objectFrom(response.data);
    return CheckoutSession(
      id: '${data['paymentId']}',
      reference: '${data['reference']}',
      link: '${data['link']}',
      callbackPath: '/payment/flutterwave/callback',
    );
  }

  Future<PaymentOutcome> verifyBookingPayment(String paymentId, String transactionId) async {
    final response = await _apiClient.post('/payments/$paymentId/verify', data: {'transactionId': transactionId});
    return _outcome(ApiClient.objectFrom(response.data)['status']);
  }

  Future<CheckoutSession> initiateWalletFunding(double amount) async {
    final response = await _apiClient.post('/wallet/funding/initiate', data: {'amount': amount});
    final data = ApiClient.objectFrom(response.data);
    return CheckoutSession(
      id: '${data['walletTransactionId']}',
      reference: '${data['reference']}',
      link: '${data['link']}',
      callbackPath: '/wallet/funding/callback',
    );
  }

  Future<PaymentOutcome> verifyWalletFunding(String walletTransactionId, String transactionId) async {
    final response = await _apiClient.post(
      '/wallet/funding/$walletTransactionId/verify',
      data: {'transactionId': transactionId},
    );
    return _outcome(ApiClient.objectFrom(response.data)['status']);
  }

  Future<WalletSummary> getWallet() async {
    final response = await _apiClient.get('/wallet');
    final data = ApiClient.objectFrom(response.data);
    return WalletSummary(
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      currency: (data['currency'] ?? 'NGN').toString(),
    );
  }

  /// Partner payout account; required before the first withdrawal.
  Future<void> updateBankDetails(BankDetails details) async {
    await _apiClient.patch('/provider/bank-details', data: {
      'bankName': details.bankName,
      'bankCode': details.bankCode,
      'accountNumber': details.accountNumber,
      'accountName': details.accountName,
    });
  }

  /// Requests a payout to the partner's saved bank account; an admin approves it.
  Future<WalletTransactionModel> requestWithdrawal(double amount) async {
    final response = await _apiClient.post('/wallet/withdrawals', data: {'amount': amount});
    return _withdrawal(ApiClient.objectFrom(response.data));
  }

  Future<List<WalletTransactionModel>> listWithdrawals() async {
    final response = await _apiClient.get('/wallet/withdrawals', queryParameters: {'per_page': 100});
    return ApiClient.listFrom(response.data).map(_withdrawal).toList();
  }

  WalletTransactionModel _withdrawal(Map<String, dynamic> json) {
    final status = '${json['status'] ?? 'PENDING'}'.toUpperCase();
    return WalletTransactionModel(
      id: '${json['id'] ?? ''}',
      title: 'Withdrawal',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      isCredit: false,
      timestamp: DateTime.tryParse('${json['createdAt'] ?? ''}')?.toLocal() ?? DateTime.now(),
      reference: '${json['reference'] ?? ''}',
      status: switch (status) {
        'PAID' => 'Completed',
        'FAILED' => 'Rejected',
        'REFUNDED' => 'Refunded',
        _ => 'Pending',
      },
    );
  }
}
