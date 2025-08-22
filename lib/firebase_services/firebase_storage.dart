// ignore_for_file: avoid_print, unnecessary_string_escapes

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and returns the download URL.
  Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String folder = 'uploads',
  }) async {
    try {
      final ref = _storage.ref('$folder/$fileName');
      await ref.putData(fileBytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  /// Deletes a file from Firebase Storage by URL.
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Delete failed: $e');
    }
  }

  /// Returns a [Reference] to a storage folder.
  Reference getFolderRef(String folder) {
    return _storage.ref(folder);
  }

  /// Lists all files in a folder and returns download URLs.
  Future<List<String>> listFilesInFolder(String folder) async {
    try {
      final result = await _storage.ref(folder).listAll();
      final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));
      return urls;
    } catch (e) {
      print('List failed: $e');
      return [];
    }
  }
}
