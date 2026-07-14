import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Picks a single image from the local device/PC.
  /// Supported types: jpg, png, jpeg, webp.
  Future<PlatformFile?> pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: true, // Crucial for Flutter Web to get bytes
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        debugPrint('Selected file name: ${file.name}');
        debugPrint('Selected file size: ${file.size} bytes');
        debugPrint('file name: ${file.name}');
        debugPrint('extension: ${file.extension}');
        debugPrint('size: ${file.size}');
        debugPrint('bytes == null ? ${file.bytes == null}');
        return file;
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  /// Picks an image from the local device and uploads it to Firebase Storage.
  /// Returns the download URL of the uploaded image.
  Future<String?> pickAndUploadImage() async {
    try {
      final file = await pickImage();
      if (file == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.extension ?? 'jpg';
      final fileName = 'prod_$timestamp.$extension';
      final path = 'products/$fileName';

      debugPrint('Selected file: ${file.name}');
      debugPrint('Upload started: $path');

      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: _getContentType(file.extension),
      );

      UploadTask task;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('File bytes are null on web');
        }
        task = ref.putData(bytes, metadata);
      } else {
        final filePath = file.path;
        if (filePath != null) {
          task = ref.putFile(io.File(filePath), metadata);
        } else if (file.bytes != null) {
          task = ref.putData(file.bytes!, metadata);
        } else {
          throw Exception('No file data available for upload');
        }
      }

      final snapshot = await task;
      debugPrint('Upload completed');

      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase upload exception: $e');
      rethrow;
    }
  }
  /// Supports both Flutter Web (using bytes) and mobile/desktop platforms.
  UploadTask? uploadProductImageTask({
    required PlatformFile file,
    required String fileName,
  }) {
    try {
      final path = 'products/$fileName';
      debugPrint('Upload started: $path');
      final ref = _storage.ref().child(path);
      final metadata = SettableMetadata(
        contentType: _getContentType(file.extension),
      );

      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('File bytes are null on web');
        }
        return ref.putData(bytes, metadata);
      } else {
        final filePath = file.path;
        if (filePath != null) {
          return ref.putFile(io.File(filePath), metadata);
        } else if (file.bytes != null) {
          return ref.putData(file.bytes!, metadata);
        } else {
          throw Exception('No file data available for upload');
        }
      }
    } catch (e) {
      debugPrint('Error creating upload task: $e');
      return null;
    }
  }

  /// Helper to determine content type based on file extension
  String _getContentType(String? extension) {
    if (extension == null) return 'image/jpeg';
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
