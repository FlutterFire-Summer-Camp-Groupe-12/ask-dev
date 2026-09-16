import 'package:askdev/core/error/exception.dart';
import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/answer_with_question.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/entities/user_activity.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl({required QuestionRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final QuestionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, QuestionSlice>> getRecentQuestions({
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) async {
    try {
      return right(
        await _remoteDataSource.getRecentQuestions(
          startAfter: startAfter,
          limit: limit,
        ),
      );
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, QuestionSlice>> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) async {
    try {
      return right(
        await _remoteDataSource.searchQuestions(
          query,
          startAfter: startAfter,
          limit: limit,
        ),
      );
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) async {
    try {
      return right(await _remoteDataSource.createQuestion(draft));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    try {
      return right(await _remoteDataSource.getQuestionById(id));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Question>> updateQuestion(
    String questionId,
    QuestionDraft draft,
  ) async {
    try {
      return right(await _remoteDataSource.updateQuestion(questionId, draft));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteQuestion(String questionId) async {
    try {
      await _remoteDataSource.deleteQuestion(questionId);
      return right(unit);
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<Answer>>> getAnswers(String questionId) async {
    try {
      return right(await _remoteDataSource.getAnswers(questionId));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Answer>> createAnswer(
    String questionId,
    AnswerDraft draft,
  ) async {
    try {
      return right(await _remoteDataSource.createAnswer(questionId, draft));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Answer>> updateAnswer(
    String questionId,
    String answerId,
    String content,
  ) async {
    try {
      return right(
        await _remoteDataSource.updateAnswer(questionId, answerId, content),
      );
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnswer(
    String questionId,
    String answerId,
  ) async {
    try {
      await _remoteDataSource.deleteAnswer(questionId, answerId);
      return right(unit);
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Stream<Either<Failure, List<Answer>>> watchAnswers(String questionId) {
    return _remoteDataSource
        .watchAnswers(questionId)
        .map<Either<Failure, List<Answer>>>((answers) => right(answers));
  }

  @override
  Future<Either<Failure, UserActivity>> getUserActivity(
    String userId, {
    int recentLimit = 5,
  }) async {
    try {
      return right(
        await _remoteDataSource.getUserActivity(
          userId,
          recentLimit: recentLimit,
        ),
      );
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByAuthor(
    String userId,
  ) async {
    try {
      return right(await _remoteDataSource.getQuestionsByAuthor(userId));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  @override
  Future<Either<Failure, List<AnswerWithQuestion>>> getAnswersByAuthor(
    String userId,
  ) async {
    try {
      return right(await _remoteDataSource.getAnswersByAuthor(userId));
    } catch (error) {
      return left(_toFailure(error));
    }
  }

  Failure _toFailure(Object error) {
    // Les agrégations (count) remontent un PlatformException plutôt qu'un
    // FirebaseException sur Android : on mappe les deux pour afficher le
    // vrai message au lieu du générique.
    if (error is NotFoundException) {
      return ServerFailure(message: error.toString());
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const ServerFailure(
            message: "Vous n'avez pas les droits pour effectuer cette action.",
          );
        case 'failed-precondition':
          // Index composite manquant : le message Firestore contient le lien
          // de création, utile en développement.
          return ServerFailure(
            message: error.message ?? 'Index Firestore manquant.',
          );
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure(message: 'Connexion réseau impossible.');
        default:
          return ServerFailure(message: error.message ?? "L'action a échoué.");
      }
    }
    if (error is PlatformException) {
      switch (error.code) {
        case 'permission-denied':
          return const ServerFailure(
            message: "Vous n'avez pas les droits pour effectuer cette action.",
          );
        case 'unavailable':
          return const NetworkFailure(message: 'Connexion réseau impossible.');
        default:
          return ServerFailure(
            message: error.message ?? "L'action a échoué.",
          );
      }
    }
    return const ServerFailure(
      message: "L'action n'a pas pu être effectuée. Réessayez.",
    );
  }
}
