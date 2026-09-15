import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/question_repository.dart';

class DeleteAnswer {
  const DeleteAnswer(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Unit>> call(String questionId, String answerId) {
    return repository.deleteAnswer(questionId, answerId);
  }
}
