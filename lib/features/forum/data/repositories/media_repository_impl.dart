import 'dart:io';

import 'package:askdev/core/error/exception.dart';
import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source.dart';
import 'package:askdev/features/forum/domain/repositories/media_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fpdart/fpdart.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl({
    required MediaRemoteDataSource remoteDataSource,
    required AuthGateway authGateway,
  }) : _remoteDataSource = remoteDataSource,
       _authGateway = authGateway;

  final MediaRemoteDataSource _remoteDataSource;
  final AuthGateway _authGateway;

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    final userId = _authGateway.currentUserId;
    if (userId == null) {
      return const Left(
        Failure(message: 'Connectez-vous pour ajouter une image.'),
      );
    }

    try {
      return right(
        await _remoteDataSource.uploadImage(userId: userId, file: file),
      );
    } on FileException catch (error) {
      return left(Failure(message: error.toString()));
    } catch (error, stackTrace) {
      AppLog.e(
        'Media',
        "Échec de l'envoi d'une image",
        error: error,
        stackTrace: stackTrace,
      );
      return left(_toFailure(error));
    }
  }

  Failure _toFailure(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unauthorized':
        case 'permission-denied':
          return const ServerFailure(
            message: "Vous n'avez pas les droits pour envoyer cette image.",
          );
        case 'unauthenticated':
          return const Failure(
            message:
                'Session expirée. Reconnectez-vous pour envoyer une '
                'image.',
          );
        // Ces trois codes signifient que le bucket visé n'existe pas : le
        // stockage n'est pas activé sur le projet Firebase, ou le nom de
        // bucket de la configuration ne correspond pas.
        case 'object-not-found':
        case 'bucket-not-found':
        case 'project-not-found':
          return const ServerFailure(
            message:
                "L'espace de stockage des images n'est pas disponible. "
                'Signalez-le à un responsable du projet.',
          );
        case 'quota-exceeded':
          return const ServerFailure(
            message: "L'espace de stockage est saturé.",
          );
        case 'canceled':
          return const Failure(message: 'Envoi annulé.');
        case 'retry-limit-exceeded':
        case 'unavailable':
          return const NetworkFailure(
            message: "Connexion trop instable pour envoyer l'image.",
          );
        default:
          return ServerFailure(
            message: error.message ?? "L'envoi de l'image a échoué.",
          );
      }
    }
    return const ServerFailure(
      message: "L'image n'a pas pu être envoyée. Réessayez.",
    );
  }
}
