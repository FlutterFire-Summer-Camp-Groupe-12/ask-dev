import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:fpdart/fpdart.dart';

abstract class QuestionRepository {
  /// Enregistre une nouvelle question et retourne la version persistée
  /// (identifiant et dates renseignés).
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft);
}
