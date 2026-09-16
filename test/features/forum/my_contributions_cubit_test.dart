import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/answer_with_question.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/entities/user_activity.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:askdev/features/forum/presentation/manager/my_contributions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

Question _question(String id) {
  final now = DateTime(2026, 9, 1);
  return Question(
    id: id,
    title: 'Question $id',
    content: 'contenu',
    authorId: 'me',
    createdAt: now,
    updatedAt: now,
    answersCount: 1,
    searchKeywords: const [],
  );
}

AnswerWithQuestion _answer(String answerId, String questionId) {
  final now = DateTime(2026, 9, 2);
  return AnswerWithQuestion(
    answer: Answer(
      id: answerId,
      content: 'réponse $answerId',
      authorId: 'me',
      createdAt: now,
      updatedAt: now,
    ),
    questionId: questionId,
    questionTitle: 'Question $questionId',
  );
}

class _FakeQuestionRepository implements QuestionRepository {
  _FakeQuestionRepository({this.questions, this.answers});

  final List<Question>? questions;
  final List<AnswerWithQuestion>? answers;

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByAuthor(
    String userId,
  ) async {
    return right(questions ?? [_question('q1')]);
  }

  @override
  Future<Either<Failure, List<AnswerWithQuestion>>> getAnswersByAuthor(
    String userId,
  ) async {
    return right(answers ?? [_answer('a1', 'q1')]);
  }

  @override
  Future<Either<Failure, QuestionSlice>> getRecentQuestions({
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, QuestionSlice>> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Question>> updateQuestion(
    String questionId,
    QuestionDraft draft,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteQuestion(String questionId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<Answer>>> getAnswers(String questionId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Answer>> createAnswer(
    String questionId,
    AnswerDraft draft,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Answer>> updateAnswer(
    String questionId,
    String answerId,
    String content,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteAnswer(
    String questionId,
    String answerId,
  ) => throw UnimplementedError();

  @override
  Stream<Either<Failure, List<Answer>>> watchAnswers(String questionId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserActivity>> getUserActivity(
    String userId, {
    int recentLimit = 5,
  }) => throw UnimplementedError();
}

void main() {
  test('load fills both lists in one go', () async {
    final cubit = MyContributionsCubit(_FakeQuestionRepository());

    await cubit.load('me');

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.questions.map((q) => q.id), ['q1']);
    expect(cubit.state.answers.map((a) => a.answer.id), ['a1']);
    expect(cubit.state.error, isNull);

    await cubit.close();
  });

  test('empty contributions stay empty without an error', () async {
    final cubit = MyContributionsCubit(
      _FakeQuestionRepository(questions: const [], answers: const []),
    );

    await cubit.load('me');

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.questions, isEmpty);
    expect(cubit.state.answers, isEmpty);
    expect(cubit.state.error, isNull);

    await cubit.close();
  });

  test('an empty userId does nothing', () async {
    final cubit = MyContributionsCubit(_FakeQuestionRepository());

    await cubit.load('');

    expect(cubit.state.isLoading, isFalse);

    await cubit.close();
  });
}