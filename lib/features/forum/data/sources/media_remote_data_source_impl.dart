import 'dart:io';

import 'package:askdev/core/error/exception.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  MediaRemoteDataSourceImpl({
    required SupabaseClient supabase,
    required String bucketId,
  }) : _supabase = supabase,
       _bucketId = bucketId;

  /// Dossier racine des images jointes aux questions et aux réponses.
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

  final SupabaseClient _supabase;
  final String _bucketId;

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
    final path =
        '$folder/$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage.from(_bucketId).upload(
      path,
      file,
      fileOptions: FileOptions(contentType: _contentTypes[extension]),
    );
    return _supabase.storage.from(_bucketId).getPublicUrl(path);
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    final extension = path.substring(dot + 1).toLowerCase();
    return _contentTypes.containsKey(extension) ? extension : 'jpg';
  }
}
