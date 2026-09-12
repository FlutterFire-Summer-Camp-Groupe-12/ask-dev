import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/create_question.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class _FakeQuestionRepository implements QuestionRepository {
  _FakeQuestionRepository({this.failure});

  final Failure? failure;
  QuestionDraft? lastDraft;

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) async {
    lastDraft = draft;
    final error = failure;
    if (error != null) return left(error);

    final now = DateTime(2026, 3, 1);
    return right(
      Question(
        id: 'q1',
        title: draft.title,
        content: draft.content,
        authorId: draft.authorId,
        type: draft.type,
        status: draft.status,
        tags: draft.tags,
        createdAt: now,
        updatedAt: now,
        answersCount: 0,
        searchKeywords: draft.searchKeywords,
      ),
    );
  }
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  AuthStatus get status =>
      currentUserId == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;

  @override
  Stream<AuthStatus> get statusStream => Stream.value(status);
}

void main() {
  const validTitle = 'Comment injecter un cubit avec get_it ?';
  final validContent = 'x' * AskQuestionState.contentMinLength;

  AskQuestionCubit buildCubit(
    _FakeQuestionRepository repository, {
    String? userId = 'u1',
  }) {
    return AskQuestionCubit(
      createQuestion: CreateQuestion(repository: repository),
      authGateway: _FakeAuthGateway(userId),
    );
  }

  void fillValidForm(AskQuestionCubit cubit) {
    cubit
      ..titleChanged(validTitle)
      ..contentChanged(validContent)
      ..tagAdded('flutter');
  }

  group('QuestionDraft', () {
    test('searchKeywords lowercases and merges title and tags', () {
      const draft = QuestionDraft(
        authorId: 'u1',
        title: 'Injecter un Cubit avec GetIt',
        content: 'peu importe',
        type: QuestionType.howTo,
        status: QuestionStatus.published,
        tags: ['flutter', 'get-it'],
      );

      expect(
        draft.searchKeywords,
        containsAll(<String>['injecter', 'un', 'cubit', 'avec', 'getit', 'flutter', 'get', 'it']),
      );
    });

    test('searchKeywords drops single-character words', () {
      const draft = QuestionDraft(
        authorId: 'u1',
        title: 'A B flutter',
        content: 'peu importe',
        type: QuestionType.howTo,
        status: QuestionStatus.published,
        tags: [],
      );

      expect(draft.searchKeywords, ['flutter']);
    });
  });

  group('AskQuestionCubit tags', () {
    test('normalizes spaces and case, and refuses duplicates', () {
      final cubit = buildCubit(_FakeQuestionRepository())
        ..tagAdded('  Clean Architecture ')
        ..tagAdded('clean-architecture');

      expect(cubit.state.tags, ['clean-architecture']);
    });

    test('stops accepting tags past the maximum', () {
      final cubit = buildCubit(_FakeQuestionRepository());
      for (var i = 0; i < AskQuestionState.maxTags + 3; i++) {
        cubit.tagAdded('tag$i');
      }

      expect(cubit.state.tags, hasLength(AskQuestionState.maxTags));
      expect(cubit.state.canAddTag, isFalse);
    });

    test('tagRemoved drops the tag', () {
      final cubit = buildCubit(_FakeQuestionRepository())
        ..tagAdded('flutter')
        ..tagAdded('dart')
        ..tagRemoved('flutter');

      expect(cubit.state.tags, ['dart']);
    });
  });

  group('AskQuestionCubit submit', () {
    test('reveals errors and skips the call when the form is incomplete', () async {
      final repository = _FakeQuestionRepository();
      final cubit = buildCubit(repository)..titleChanged('trop court');

      await cubit.submit();

      expect(cubit.state.showErrors, isTrue);
      expect(cubit.state.titleError, isNotNull);
      expect(cubit.state.tagsError, isNotNull);
      expect(repository.lastDraft, isNull);
    });

    test('sends a trimmed draft and resets the form on success', () async {
      final repository = _FakeQuestionRepository();
      final cubit = buildCubit(repository);
      fillValidForm(cubit);
      cubit.statusChanged(QuestionStatus.published);

      await cubit.submit();

      expect(repository.lastDraft?.authorId, 'u1');
      expect(repository.lastDraft?.title, validTitle);
      expect(repository.lastDraft?.status, QuestionStatus.published);
      expect(repository.lastDraft?.tags, ['flutter']);
      expect(cubit.state.published?.id, 'q1');
      expect(cubit.state.title, isEmpty);
      expect(cubit.state.tags, isEmpty);
      expect(cubit.state.isSubmitting, isFalse);
    });

    test('keeps the form and surfaces the message on failure', () async {
      final repository = _FakeQuestionRepository(
        failure: const ServerFailure(message: 'Firestore indisponible'),
      );
      final cubit = buildCubit(repository);
      fillValidForm(cubit);

      await cubit.submit();

      expect(cubit.state.error, 'Firestore indisponible');
      expect(cubit.state.published, isNull);
      expect(cubit.state.title, validTitle);
      expect(cubit.state.isSubmitting, isFalse);
    });

    test('refuses to publish without a signed-in user', () async {
      final repository = _FakeQuestionRepository();
      final cubit = buildCubit(repository, userId: null);
      fillValidForm(cubit);

      await cubit.submit();

      expect(repository.lastDraft, isNull);
      expect(cubit.state.error, isNotNull);
    });
  });
}
