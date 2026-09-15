import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question_slice.dart';
import '../repositories/question_repository.dart';

class GetRecentQuestions {
  const GetRecentQuestions(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, QuestionSlice>> call({String? startAfter}) {
    return repository.getRecentQuestions(startAfter: startAfter);
  }
}
