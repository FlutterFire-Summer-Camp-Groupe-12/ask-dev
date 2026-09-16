import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_activity.dart';
import '../repositories/question_repository.dart';

class GetUserActivity {
  const GetUserActivity(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, UserActivity>> call(String userId) {
    return repository.getUserActivity(userId);
  }
}
