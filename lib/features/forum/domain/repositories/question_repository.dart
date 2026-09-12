import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question.dart';

abstract class QuestionRepository {
  Future<Either<Failure, List<Question>>> getRecentQuestions();
}