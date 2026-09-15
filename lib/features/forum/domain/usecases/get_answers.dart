import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/answer.dart';
import '../repositories/question_repository.dart';

class GetAnswers {
  const GetAnswers(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, List<Answer>>> call(String questionId) {
    return repository.getAnswers(questionId);
  }
}
