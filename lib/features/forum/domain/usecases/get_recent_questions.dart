import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetRecentQuestions {
  const GetRecentQuestions(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, List<Question>>> call() {
    return repository.getRecentQuestions();
  }
}