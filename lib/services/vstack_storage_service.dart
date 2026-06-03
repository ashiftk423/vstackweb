import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class VStackStorageService {
  VStackStorageService(this._storage);

  final FirebaseStorage _storage;

  /// Upload bytes and return public URL + storage path for Firestore.
  Future<({String url, String path})> upload({
    required String storagePath,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ref = _storage.ref(storagePath);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    final url = await ref.getDownloadURL();
    return (url: url, path: storagePath);
  }

  /// Remove a file when content is updated or deleted — keeps storage lean.
  Future<void> deletePath(String? storagePath) async {
    if (storagePath == null || storagePath.trim().isEmpty) return;
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
