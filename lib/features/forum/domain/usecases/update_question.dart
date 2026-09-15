import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question.dart';
import '../entities/question_draft.dart';
import '../repositories/question_repository.dart';

class UpdateQuestion {
  const UpdateQuestion(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Question>> call(
    String questionId,
    QuestionDraft draft,
  ) {
    return repository.updateQuestion(questionId, draft);
  }
}
