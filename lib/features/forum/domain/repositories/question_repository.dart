import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:fpdart/fpdart.dart';

abstract class QuestionRepository {
  /// Nombre de questions par page, dans le fil comme dans la recherche.
  static const int pageSize = 20;

  /// Page du fil public, de la plus récente à la plus ancienne. Passer le
  /// [QuestionSlice.nextCursor] de la page précédente dans [startAfter].
  Future<Either<Failure, QuestionSlice>> getRecentQuestions({
    String? startAfter,
    int limit = pageSize,
  });

  /// Page de questions correspondant à [query] (titre, tags et description),
  /// de la plus récente à la plus ancienne.
  Future<Either<Failure, QuestionSlice>> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    int limit = pageSize,
  });

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
}