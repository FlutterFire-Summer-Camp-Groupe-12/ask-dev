import 'dart:io';

import 'package:askdev/core/error/exception.dart';
import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source.dart';
import 'package:askdev/features/forum/domain/repositories/media_repository.dart';
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
    return const ServerFailure(
      message: "L'image n'a pas pu être envoyée. Réessayez.",
    );
  }
}
