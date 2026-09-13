import 'package:askdev/features/forum/data/models/question_model.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';

abstract class QuestionRemoteDataSource {
  /// Liste les dernières questions du fil public.
  Future<List<QuestionModel>> getRecentQuestions();

  /// Crée le document Firestore correspondant à [draft].
  Future<QuestionModel> createQuestion(QuestionDraft draft);
}