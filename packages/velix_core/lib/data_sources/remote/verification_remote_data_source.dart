import 'package:dio/dio.dart';
import '../../network/api_client.dart';
import '../../network/upload_file.dart';

/// Review state of a customer's driver's licence or a partner's KYC documents.
class VerificationStatus {
  /// null (nothing submitted), 'PENDING', 'ACTIVE'/'VERIFIED' (approved) or 'REJECTED'.
  final String? status;
  final String? rejectionReason;
  VerificationStatus({this.status, this.rejectionReason});

  bool get isApproved => status == 'ACTIVE' || status == 'VERIFIED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';

  factory VerificationStatus.fromJson(Map<String, dynamic> json) => VerificationStatus(
        status: json['status']?.toString(),
        rejectionReason: json['rejectionReason']?.toString(),
      );
}

class VerificationRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  // The backend's upload middleware only accepts fields named `<prefix>0`, `<prefix>1`, ...
  Future<FormData> _form(List<UploadFile> files, String prefix, [Map<String, String> fields = const {}]) async {
    if (files.isEmpty) throw ApiException('Please add at least one document.');
    return FormData.fromMap({
      ...fields,
      for (var i = 0; i < files.length; i++) '$prefix$i': await files[i].toMultipart(),
    });
  }

  Future<VerificationStatus> uploadCustomerDocuments(List<UploadFile> files) async {
    await _apiClient.post('/customer/documents', data: await _form(files, 'customer_document_'));
    return customerStatus();
  }

  /// [companyName] is saved as the partner's business name (shown on their listings).
  Future<VerificationStatus> uploadPartnerDocuments(List<UploadFile> files, {String? companyName}) async {
    final fields = {if (companyName != null && companyName.trim().isNotEmpty) 'companyName': companyName.trim()};
    await _apiClient.post('/provider/documents', data: await _form(files, 'provider_document_', fields));
    return partnerStatus();
  }

  Future<VerificationStatus> customerStatus() async {
    final response = await _apiClient.get('/customer/verification-status');
    return VerificationStatus.fromJson(ApiClient.objectFrom(response.data));
  }

  Future<VerificationStatus> partnerStatus() async {
    final response = await _apiClient.get('/provider/verification-status');
    return VerificationStatus.fromJson(ApiClient.objectFrom(response.data));
  }
}
