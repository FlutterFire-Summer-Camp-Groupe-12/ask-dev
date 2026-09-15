import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetQuestionById {
  const GetQuestionById(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, Question>> call(String id) {
    return repository.getQuestionById(id);
  }
}
