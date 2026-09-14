import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:fpdart/fpdart.dart';

abstract class QuestionRepository {
  /// Liste des questions récentes du fil public.
  Future<Either<Failure, List<Question>>> getRecentQuestions();

  /// Enregistre une nouvelle question et retourne la version persistée
  /// (identifiant et dates renseignés).
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft);

  /// Charge une question par son identifiant.
  Future<Either<Failure, Question>> getQuestionById(String id);

  /// Liste des réponses d'une question, de la plus ancienne à la plus récente.
  Future<Either<Failure, List<Answer>>> getAnswers(String questionId);

  /// Enregistre une réponse sous la question et met à jour son compteur.
  Future<Either<Failure, Answer>> createAnswer(
    String questionId,
    AnswerDraft draft,
  );
  
  /// Modifie le contenu d'une réponse existante. L'appelant est
  /// responsable de vérifier que l'utilisateur courant en est bien
  /// l'auteur avant d'appeler cette méthode.
  Future<Either<Failure, Answer>> updateAnswer(
    String questionId,
    String answerId,
    String content,
  );

  /// Supprime une réponse. Même remarque que pour [updateAnswer].
  Future<Either<Failure, Unit>> deleteAnswer(String questionId, String answerId);

  /// Flux temps réel des réponses d'une question.
  Stream<Either<Failure, List<Answer>>> watchAnswers(String questionId);
}
