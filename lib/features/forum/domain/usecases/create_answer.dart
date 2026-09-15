import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/answer.dart';
import '../entities/answer_draft.dart';
import '../repositories/question_repository.dart';

class CreateAnswer {
  const CreateAnswer(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Answer>> call(String questionId, AnswerDraft draft) {
    return repository.createAnswer(questionId, draft);
  }
}
