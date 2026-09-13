import 'package:askdev/core/base/usecase.dart';
import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateQuestion implements UseCase<Question, QuestionDraft> {
  const CreateQuestion({required QuestionRepository repository})
      : _repository = repository;

  final QuestionRepository _repository;

  @override
  Future<Either<Failure, Question>> call(QuestionDraft params) {
    return _repository.createQuestion(params);
  }
}
