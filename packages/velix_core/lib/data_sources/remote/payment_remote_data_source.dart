import '../../models/payment_model.dart';
import '../../network/api_client.dart';

class PaymentRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String email,
  }) async {
    final response = await _apiClient.post('/payments/initialize', data: {
      'amount': amount,
      'email': email,
    });
    return response.data['data'] ?? {};
  }

  Future<bool> verifyPayment(String reference) async {
    final response = await _apiClient.post('/payments/verify', data: {
      'reference': reference,
    });
    return response.data['success'] == true;
  }

  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _apiClient.get('/wallet/balance');
    return response.data['data'] ?? {'balance': 0.0, 'transactions': []};
  }

  Future<WalletTransactionModel> withdraw({
    required double amount,
    required String bankCode,
    required String accountNumber,
  }) async {
    final response = await _apiClient.post('/wallet/withdraw', data: {
      'amount': amount,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
    });
    final json = response.data['data'];
    return WalletTransactionModel(
      id: json['id'] ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Bank Withdrawal',
      amount: (json['amount'] as num?)?.toDouble() ?? amount,
      isCredit: json['isCredit'] ?? false,
      timestamp: DateTime.now(),
      reference: json['reference'] ?? 'WITH-REF',
    );
  }
}
