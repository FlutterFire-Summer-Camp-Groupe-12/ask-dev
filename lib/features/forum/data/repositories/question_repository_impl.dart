import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../sources/question_remote_source.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  const QuestionRepositoryImpl(this.remoteSource);

  final QuestionRemoteSource remoteSource;

  @override
  Future<Either<Failure, List<Question>>> getRecentQuestions() async {
    try {
      final questions = await remoteSource.getRecentQuestions();
      return Right(questions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.toString()));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}