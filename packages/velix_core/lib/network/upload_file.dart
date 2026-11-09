import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// A file picked on the device, for multipart uploads. [bytes] is used when available (web, or
/// a picker that returns bytes); otherwise the file at [path] is read.
class UploadFile {
  final String name;
  final String? path;
  final Uint8List? bytes;
  UploadFile({required this.name, this.path, this.bytes});

  Future<MultipartFile> toMultipart() async {
    if (bytes != null && bytes!.isNotEmpty) return MultipartFile.fromBytes(bytes!, filename: name);
    if (path != null && !kIsWeb) return MultipartFile.fromFile(path!, filename: name);
    throw ApiException('Could not read "$name". Please pick the file again.');
  }
}
