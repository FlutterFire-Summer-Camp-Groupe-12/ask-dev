import 'dart:io';

import 'package:askdev/core/error/exception.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  MediaRemoteDataSourceImpl({required FirebaseStorage storage})
    : _storage = storage;

  /// Dossier racine des images jointes aux questions et aux réponses. Les
  /// règles de sécurité limitent l'écriture au dossier de chaque auteur.
  static const String folder = 'post_images';

  /// Les images sont déjà réduites à la sélection ; au-delà, on refuse plutôt
  /// que de faire attendre l'utilisateur sur un envoi long.
  static const int maxBytes = 5 * 1024 * 1024;

  static const Map<String, String> _contentTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'heic': 'image/heic',
  };

  final FirebaseStorage _storage;

  @override
  Future<String> uploadImage({
    required String userId,
    required File file,
  }) async {
    final bytes = await file.length();
    if (bytes > maxBytes) {
      throw FileException(
        message:
            'Image trop lourde (${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo). '
            'Maximum ${maxBytes ~/ (1024 * 1024)} Mo.',
      );
    }

    final extension = _extensionOf(file.path);
    final reference = _storage
        .ref(folder)
        .child('$userId/${DateTime.now().millisecondsSinceEpoch}.$extension');

    await reference.putFile(
      file,
      SettableMetadata(contentType: _contentTypes[extension]),
    );
    return reference.getDownloadURL();
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    final extension = path.substring(dot + 1).toLowerCase();
    return _contentTypes.containsKey(extension) ? extension : 'jpg';
  }
}
