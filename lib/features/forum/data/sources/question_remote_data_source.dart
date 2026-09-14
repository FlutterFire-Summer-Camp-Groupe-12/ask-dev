import 'package:askdev/features/forum/data/models/answer_model.dart';
import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';

abstract class QuestionRemoteDataSource {
  /// Liste les dernières questions du fil public.
  Future<List<QuestionModel>> getRecentQuestions();

  /// Crée le document Firestore correspondant à [draft].
  Future<QuestionModel> createQuestion(QuestionDraft draft);

  /// Charge un document question par son identifiant.
  Future<QuestionModel> getQuestionById(String id);

  /// Réponses d'une question (sous-collection), de la plus ancienne à la plus
  /// récente.
  Future<List<AnswerModel>> getAnswers(String questionId);

  /// Enregistre une réponse sous la question et incrémente son compteur.
  Future<AnswerModel> createAnswer(String questionId, AnswerDraft draft);
  /// Modifie le contenu d'une réponse existante.
  Future<AnswerModel> updateAnswer(String questionId, String answerId, String content);

  /// Supprime une réponse et décrémente le compteur de la question.
  Future<void> deleteAnswer(String questionId, String answerId);

  /// Flux temps réel des réponses d'une question (mise à jour en direct,
  /// sans avoir à rappeler getAnswers()).
  Stream<List<AnswerModel>> watchAnswers(String questionId);
}

  