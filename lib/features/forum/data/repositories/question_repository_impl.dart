import 'package:askdev/core/error/exception.dart';
import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl({required QuestionRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final QuestionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<Question>>> getRecentQuestions() async {
    try {
      final questions = await _remoteDataSource.getRecentQuestions();
      return right(questions);
    } on ServerException catch (e) {
      return left(ServerFailure(message: e.toString()));
    } catch (e) {
      return left(ServerFailure(message: e.toString()));
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

  Failure _toFailure(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const ServerFailure(
            message: "Vous n'avez pas les droits pour effectuer cette action.",
          );
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure(message: 'Connexion réseau impossible.');
        default:
          return ServerFailure(message: error.message ?? "L'action a échoué.");
      }
    }
    return const ServerFailure(
      message: "L'action n'a pas pu être effectuée. Réessayez.",
    );
  }
}