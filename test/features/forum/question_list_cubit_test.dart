import 'dart:async';

import 'package:askdev/core/error/failure.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/entities/user_activity.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:askdev/features/forum/domain/usecases/get_recent_questions.dart';
import 'package:askdev/features/forum/domain/usecases/search_questions.dart';
import 'package:askdev/features/forum/presentation/manager/question_list_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

Question _question(String id) {
  final now = DateTime(2026, 9, 1);
  return Question(
    id: id,
    title: 'Question $id',
    content: 'contenu',
    authorId: 'u1',
    createdAt: now,
    updatedAt: now,
    answersCount: 0,
    searchKeywords: const [],
  );
}

class _FakeQuestionRepository implements QuestionRepository {
  /// Pages du fil, indexées par curseur (`null` pour la première).
  final Map<String?, Either<Failure, QuestionSlice>> recentPages = {};

  /// Réponses de recherche, indexées par mot pivot.
  final Map<String, Completer<Either<Failure, QuestionSlice>>> searches = {};

  final List<String?> recentCursors = [];
  final List<String?> searchedAnchors = [];

  @override
  Future<Either<Failure, QuestionSlice>> getRecentQuestions({
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) async {
    recentCursors.add(startAfter);
    return recentPages[startAfter]!;
  }

  @override
  Future<Either<Failure, QuestionSlice>> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) {
    searchedAnchors.add(query.anchor);
    return searches.putIfAbsent(query.anchor!, Completer.new).future;
  }

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) =>
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
  Future<Either<Failure, Question>> updateQuestion(
    String questionId,
    QuestionDraft draft,
  ) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> deleteQuestion(String questionId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, UserActivity>> getUserActivity(
    String userId, {
    int recentLimit = 5,
  }) => throw UnimplementedError();
}

void main() {
  late _FakeQuestionRepository repository;

  QuestionListCubit buildCubit() {
    return QuestionListCubit(
      getRecentQuestions: GetRecentQuestions(repository),
      searchQuestions: SearchQuestions(repository),
      searchDelay: Duration.zero,
    );
  }

  setUp(() {
    repository = _FakeQuestionRepository();
  });

  test(
    'load then loadMore appends the next page and stops at the end',
    () async {
      repository.recentPages[null] = right(
        QuestionSlice(
          questions: [_question('q1'), _question('q2')],
          nextCursor: 'q2',
        ),
      );
      repository.recentPages['q2'] = right(
        QuestionSlice(questions: [_question('q3')]),
      );
      final cubit = buildCubit();

      await cubit.load();
      expect(cubit.state.status, QuestionListStatus.success);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.questions.map((q) => q.id), ['q1', 'q2', 'q3']);
      expect(cubit.state.hasMore, isFalse);

      await cubit.loadMore();
      expect(repository.recentCursors, [null, 'q2']);
    },
  );

  test('a failed next page keeps the loaded questions', () async {
    repository.recentPages[null] = right(
      QuestionSlice(questions: [_question('q1')], nextCursor: 'q1'),
    );
    repository.recentPages['q1'] = left(
      const ServerFailure(message: 'hors ligne'),
    );
    final cubit = buildCubit();

    await cubit.load();
    await cubit.loadMore();

    expect(cubit.state.questions, hasLength(1));
    expect(cubit.state.loadMoreError, 'hors ligne');
    expect(cubit.state.nextCursor, 'q1');
  });

  test('search queries the repository and ignores a stale response', () async {
    repository.recentPages[null] = right(
      QuestionSlice(questions: [_question('q1')]),
    );
    final cubit = buildCubit();
    await cubit.load();

    cubit.search('firestore ');
    await Future<void>.delayed(Duration.zero);
    cubit.search('riverpod ');
    await Future<void>.delayed(Duration.zero);

    // La réponse à « riverpod » arrive avant celle à « firestore ».
    repository.searches['riverpod']!.complete(
      right(QuestionSlice(questions: [_question('r1')])),
    );
    await Future<void>.delayed(Duration.zero);
    repository.searches['firestore']!.complete(
      right(QuestionSlice(questions: [_question('f1')])),
    );
    await Future<void>.delayed(Duration.zero);

    expect(repository.searchedAnchors, ['firestore', 'riverpod']);
    expect(cubit.state.query, 'riverpod ');
    expect(cubit.state.questions.map((q) => q.id), ['r1']);
  });

  test(
    'a query made only of stop words shows the feed without a search',
    () async {
      repository.recentPages[null] = right(
        QuestionSlice(questions: [_question('q1')]),
      );
      final cubit = buildCubit();
      await cubit.load();

      cubit.search('le la ');
      await Future<void>.delayed(Duration.zero);

      expect(repository.searchedAnchors, isEmpty);
      expect(cubit.state.questions.map((q) => q.id), ['q1']);
    },
  );
}
