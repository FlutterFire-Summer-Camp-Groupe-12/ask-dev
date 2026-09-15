import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/question_repository.dart';

class DeleteQuestion {
  const DeleteQuestion(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Unit>> call(String questionId) {
    return repository.deleteQuestion(questionId);
  }
}
