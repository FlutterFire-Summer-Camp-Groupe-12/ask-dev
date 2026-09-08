import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetRecentQuestions {
  final QuestionRepository repository;
  const GetRecentQuestions(this.repository);

  Future<Either<Failure, List<Question>>> call() {
    return repository.getRecentQuestions();
  }
}