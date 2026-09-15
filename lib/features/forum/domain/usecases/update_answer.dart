import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/answer.dart';
import '../repositories/question_repository.dart';

class UpdateAnswer {
  const UpdateAnswer(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Answer>> call(
    String questionId,
    String answerId,
    String content,
  ) {
    return repository.updateAnswer(questionId, answerId, content);
  }
}
