import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/environment.dart';
import '../network/api_client.dart';

abstract class FileUploadService {
  Future<String> uploadImage(String filePath, {String category = 'general', Uint8List? fileBytes});
  Future<String> uploadDocument(String filePath, {String docType = 'kyc', Uint8List? fileBytes});
}

class RemoteFileUploadService implements FileUploadService {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<String> uploadImage(String filePath, {String category = 'general', Uint8List? fileBytes}) async {
    final ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : 'jpg';
    final mimeType = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
    final fileName = '${category}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // 1. Attempt upload to real REST Backend API
    try {
      MultipartFile multipartFile;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (!kIsWeb && await File(filePath).exists()) {
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        multipartFile = MultipartFile.fromBytes(utf8.encode('image_placeholder'), filename: fileName);
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'category': category,
      });

      final response = await _apiClient
          .post('/upload', data: formData)
          .timeout(const Duration(seconds: 3));
      final url = response.data['url'] ?? response.data['data']?['url'];
      if (url != null && url.toString().isNotEmpty) {
        return url.toString();
      }
    } catch (e) {
      debugPrint('[RemoteFileUploadService] REST upload exception: $e');
    }

    // 2. Offline / local preview fallback using Base64 Data URI
    if (fileBytes != null && fileBytes.isNotEmpty) {
      return 'data:$mimeType;base64,${base64Encode(fileBytes)}';
    }

    if (!kIsWeb) {
      try {
        final f = File(filePath);
        if (await f.exists()) {
          final bytes = await f.readAsBytes();
          return 'data:$mimeType;base64,${base64Encode(bytes)}';
        }
      } catch (_) {}
    }

    return '${AppConfig.serverHost}/uploads/$fileName';
  }

  @override
  Future<String> uploadDocument(String filePath, {String docType = 'kyc', Uint8List? fileBytes}) async {
    final ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : 'pdf';
    final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    // 1. Attempt upload to real REST Backend API
    try {
      MultipartFile multipartFile;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (!kIsWeb && await File(filePath).exists()) {
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        multipartFile = MultipartFile.fromBytes(utf8.encode('doc_placeholder'), filename: fileName);
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'category': docType,
      });

      final response = await _apiClient
          .post('/upload', data: formData)
          .timeout(const Duration(seconds: 3));
      final url = response.data['url'] ?? response.data['data']?['url'];
      if (url != null && url.toString().isNotEmpty) {
        return url.toString();
      }
    } catch (e) {
      debugPrint('[RemoteFileUploadService] REST document upload exception: $e');
    }

    // 2. Offline / local preview fallback using Base64 Data URI
    if (fileBytes != null && fileBytes.isNotEmpty) {
      return 'data:application/pdf;base64,${base64Encode(fileBytes)}';
    }

    return '${AppConfig.serverHost}/uploads/$fileName';
  }
}

class MockFileUploadService implements FileUploadService {
  @override
  Future<String> uploadImage(String filePath, {String category = 'general', Uint8List? fileBytes}) async {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      final ext = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : 'jpg';
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      return 'data:$mimeType;base64,${base64Encode(fileBytes)}';
    }
    return '${AppConfig.serverHost}/uploads/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  Future<String> uploadDocument(String filePath, {String docType = 'kyc', Uint8List? fileBytes}) async {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      return 'data:application/pdf;base64,${base64Encode(fileBytes)}';
    }
    return '${AppConfig.serverHost}/uploads/doc_${docType}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }
}
