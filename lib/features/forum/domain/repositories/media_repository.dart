import 'dart:io';

import 'package:askdev/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract class MediaRepository {
  /// Envoie une image jointe à une question ou une réponse et retourne son
  /// URL publique, à insérer en Markdown dans le texte.
  Future<Either<Failure, String>> uploadImage(File file);
}
