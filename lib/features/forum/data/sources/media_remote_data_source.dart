import 'dart:io';

abstract class MediaRemoteDataSource {
  /// Envoie [file] dans le dossier de l'utilisateur et retourne son URL de
  /// téléchargement.
  Future<String> uploadImage({required String userId, required File file});
}
