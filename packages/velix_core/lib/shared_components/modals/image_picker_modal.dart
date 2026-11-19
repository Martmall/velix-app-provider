import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../network/upload_file.dart';

import 'package:velix_core/theme/velix_palette.dart';
/// Lets the user pick a photo (camera/gallery) or a document, and returns it as an [UploadFile].
/// Picking only -- the caller uploads it to the endpoint that fits (vehicle photos, verification
/// documents, ...), so nothing is reported as "uploaded" before the server has actually accepted it.
class ImagePickerModal {
  static Future<UploadFile?> show({
    required BuildContext context,
    String title = 'Upload Photo',
    bool isVehicle = false,
    bool isDocument = false,
    String category = 'general',
  }) async {
    return showModalBottomSheet<UploadFile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ImagePickerSheet(
        title: title,
        isVehicle: isVehicle,
        isDocument: isDocument,
        category: category,
      ),
    );
  }
}

class _ImagePickerSheet extends StatefulWidget {
  final String title;
  final bool isVehicle;
  final bool isDocument;
  final String category;

  const _ImagePickerSheet({
    required this.title,
    required this.isVehicle,
    required this.isDocument,
    required this.category,
  });

  @override
  State<_ImagePickerSheet> createState() => _ImagePickerSheetState();
}

class _ImagePickerSheetState extends State<_ImagePickerSheet> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _handleFilePick({required bool fromCamera, required bool isDoc}) async {
    try {
      String? filePath;
      Uint8List? fileBytes;
      String? fileName;

      if (isDoc) {
        // PDF / KYC Document picker (used for Business Verification & KYC)
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            withData: true,
          );
          if (result != null && result.files.isNotEmpty) {
            final picked = result.files.first;
            filePath = picked.path;
            fileBytes = picked.bytes;
            fileName = picked.name;
          }
        } catch (_) {
          try {
            final picked = await _picker.pickImage(source: ImageSource.gallery);
            if (picked != null) {
              filePath = picked.path;
              fileBytes = await picked.readAsBytes();
              fileName = picked.name;
            }
          } catch (_) {}
        }
      } else if (fromCamera) {
        // Explicit Camera Capture (Device Camera)
        try {
          final picked = await _picker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear,
            imageQuality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          if (picked != null) {
            filePath = picked.path;
            fileBytes = await picked.readAsBytes();
            fileName = picked.name;
          }
        } catch (camErr) {
          // If native camera is unavailable (e.g. desktop simulator without webcam), fallback to image file picker
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            if (result != null && result.files.isNotEmpty) {
              final picked = result.files.first;
              filePath = picked.path;
              fileBytes = picked.bytes;
              fileName = picked.name;
            }
          } catch (_) {}
        }
      } else {
        // Photo Gallery / File Picker
        try {
          final picked = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          if (picked != null) {
            filePath = picked.path;
            fileBytes = await picked.readAsBytes();
            fileName = picked.name;
          }
        } catch (_) {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            if (result != null && result.files.isNotEmpty) {
              final picked = result.files.first;
              filePath = picked.path;
              fileBytes = picked.bytes;
              fileName = picked.name;
            }
          } catch (_) {}
        }
      }

      if ((filePath != null || fileBytes != null) && mounted) {
        final name = fileName ?? filePath?.split('/').last ?? 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Navigator.of(context).pop(UploadFile(name: name, path: filePath, bytes: fileBytes));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: VelixPalette.claim,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? VelixPalette.nightPaper : VelixPalette.paper;
    final titleColor = isDark ? VelixPalette.paper : VelixPalette.ink;
    final borderColor = isDark ? VelixPalette.nightLine : VelixPalette.line;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? VelixPalette.nightLineStrong : VelixPalette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : VelixPalette.muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_isUploading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: VelixPalette.copper),
                    SizedBox(height: 12),
                    Text(
                      'Uploading file...',
                      style: TextStyle(fontSize: 13, color: VelixPalette.muted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _handleFilePick(fromCamera: true, isDoc: false),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? VelixPalette.nightCopperSoft : VelixPalette.copperSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: VelixPalette.copper.withValues(alpha: 0.4)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.camera_alt, color: VelixPalette.copper, size: 28),
                                SizedBox(height: 6),
                                Text(
                                  'Take Photo',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: VelixPalette.copper),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _handleFilePick(fromCamera: false, isDoc: false),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark ? VelixPalette.nightStone3 : VelixPalette.stone,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.photo_library, color: isDark ? VelixPalette.paper : VelixPalette.ink, size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  'Photo Gallery',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? VelixPalette.paper : VelixPalette.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Render PDF/Document picker ONLY when isDocument is true (e.g. Business Verification & KYC)
                  if (widget.isDocument) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _handleFilePick(fromCamera: false, isDoc: true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? VelixPalette.nightStone3 : VelixPalette.stone,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf, color: VelixPalette.claim, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Choose PDF / File from Device Storage',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? VelixPalette.paper : VelixPalette.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
