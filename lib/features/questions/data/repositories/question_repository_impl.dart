import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../sources/question_remote_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteSource remoteSource;
  QuestionRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, List<Question>>> getRecentQuestions() async {
    try {
      final questions = await remoteSource.getRecentQuestions();
      return Right(questions);
    } catch (e) {
      return Left(Failure(message: 'Impossible de charger les questions : $e'));
    }
  }
}