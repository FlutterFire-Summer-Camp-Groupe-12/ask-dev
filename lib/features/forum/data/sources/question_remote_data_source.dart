import 'package:askdev/features/forum/data/models/answer_model.dart';
import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';

abstract class QuestionRemoteDataSource {
  /// Page du fil public, triée par date de création décroissante.
  Future<QuestionSlice> getRecentQuestions({
    String? startAfter,
    required int limit,
  });

  /// Page de résultats de recherche, triée par date de création décroissante.
  Future<QuestionSlice> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    required int limit,
  });

  /// Crée le document Firestore correspondant à [draft].
  Future<QuestionModel> createQuestion(QuestionDraft draft);

  /// Charge un document question par son identifiant.
  Future<QuestionModel> getQuestionById(String id);

  /// Remplace le contenu d'une question existante (titre, description, type,
  /// tags). L'auteur et les dates de création sont conservés.
  Future<QuestionModel> updateQuestion(String questionId, QuestionDraft draft);

  /// Supprime une question et toutes ses réponses.
  Future<void> deleteQuestion(String questionId);

  /// Réponses d'une question (sous-collection), de la plus ancienne à la plus
  /// récente.
  Future<List<AnswerModel>> getAnswers(String questionId);

  /// Enregistre une réponse sous la question et incrémente son compteur.
  Future<AnswerModel> createAnswer(String questionId, AnswerDraft draft);

  /// Modifie le contenu d'une réponse existante.
  Future<AnswerModel> updateAnswer(
    String questionId,
    String answerId,
    String content,
  );

  /// Supprime une réponse et décrémente le compteur de la question.
  Future<void> deleteAnswer(String questionId, String answerId);

  /// Flux temps réel des réponses d'une question (mise à jour en direct,
  /// sans avoir à rappeler getAnswers()).
  Stream<List<AnswerModel>> watchAnswers(String questionId);
}
