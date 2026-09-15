import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/get_answers.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

final _now = DateTime(2026, 9, 1, 12);

Question _question({int answersCount = 0}) {
  return Question(
    id: 'q1',
    title: 'Comment état vide sur une liste ?',
    content: 'J’aimerais afficher un empty state.',
    authorId: 'u0',
    createdAt: _now,
    updatedAt: _now,
    answersCount: answersCount,
    searchKeywords: const [],
  );
}

Answer _answer(String id, {String authorId = 'u1'}) {
  return Answer(
    id: id,
    content: 'Réponse $id',
    authorId: authorId,
    createdAt: _now.add(Duration(hours: id.hashCode % 5)),
    updatedAt: _now,
  );
}

class _FakeQuestionRepository implements QuestionRepository {
  _FakeQuestionRepository({
    this.question,
    this.answers = const [],
    this.questionFailure,
    this.answerFailure,
  });

  final Question? question;
  final List<Answer> answers;
  final Failure? questionFailure;
  final Failure? answerFailure;

  AnswerDraft? lastDraft;
  String? lastQuestionId;

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    final failure = questionFailure;
    if (failure != null) return left(failure);
    return right(question!);
  }

  @override
  Future<Either<Failure, List<Answer>>> getAnswers(String questionId) async {
    return right(answers);
  }

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, QuestionSlice>> getRecentQuestions({
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) async {
    return right(QuestionSlice(questions: [question ?? _question()]));
  }

  @override
  Future<Either<Failure, QuestionSlice>> searchQuestions(
    SearchQuery query, {
    String? startAfter,
    int limit = QuestionRepository.pageSize,
  }) async {
    return right(QuestionSlice.empty);
  }

  @override
  Future<Either<Failure, Answer>> createAnswer(
    String questionId,
    AnswerDraft draft,
  ) async {
    lastQuestionId = questionId;
    lastDraft = draft;
    final failure = answerFailure;
    if (failure != null) return left(failure);
    return right(_answer('a-new', authorId: draft.authorId));
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

QuestionDetailCubit _buildCubit(
  _FakeQuestionRepository repository, {
  String? userId = 'u1',
}) {
  return QuestionDetailCubit(
    questionId: 'q1',
    getQuestionById: GetQuestionById(repository),
    getAnswers: GetAnswers(repository),
    createAnswer: CreateAnswer(repository),
    authGateway: _FakeAuthGateway(userId),
  );
}

void main() {
  group('QuestionDetailCubit load', () {
    test('charges la question et ses réponses', () async {
      final cubit = _buildCubit(
        _FakeQuestionRepository(question: _question(), answers: [_answer('a1')]),
      );

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<QuestionDetailLoaded>());
      final loaded = state as QuestionDetailLoaded;
      expect(loaded.question.id, 'q1');
      expect(loaded.answers, hasLength(1));
    });

    test('émet une erreur quand la question est introuvable', () async {
      final cubit = _buildCubit(
        _FakeQuestionRepository(
          questionFailure:
              const ServerFailure(message: 'Question inexistante'),
        ),
      );

      await cubit.load();

      expect(cubit.state, const QuestionDetailError('Question inexistante'));
    });
  });

  group('QuestionDetailCubit submitAnswer', () {
    test('refuse un contenu vide sans appeler le dépôt', () async {
      final repository = _FakeQuestionRepository(question: _question());
      final cubit = _buildCubit(repository);
      await cubit.load();

      await cubit.submitAnswer('   ');

      expect(repository.lastDraft, isNull);
      expect((cubit.state as QuestionDetailLoaded).answerError, isNotNull);
    });

    test('envoie un brouillon nettoyé, ajoute la réponse et incrémente le compteur', () async {
      final repository = _FakeQuestionRepository(question: _question());
      final cubit = _buildCubit(repository);
      await cubit.load();

      await cubit.submitAnswer('   Voici ma réponse.  ');

      expect(repository.lastQuestionId, 'q1');
      expect(repository.lastDraft?.content, 'Voici ma réponse.');
      expect(repository.lastDraft?.authorId, 'u1');
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.question.answersCount, 1);
      expect(state.answers, hasLength(1));
      expect(state.published?.id, 'a-new');
      expect(state.isSubmitting, isFalse);
    });

    test('conserve les réponses existantes et affiche le message d’échec', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1')],
        answerFailure: const ServerFailure(message: 'Firestore indisponible'),
      );
      final cubit = _buildCubit(repository);
      await cubit.load();

      await cubit.submitAnswer('Ma réponse');

      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerError, 'Firestore indisponible');
      expect(state.answers, hasLength(1));
      expect(state.published, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('refuse de répondre sans utilisateur connecté', () async {
      final repository = _FakeQuestionRepository(question: _question());
      final cubit = _buildCubit(repository, userId: null);
      await cubit.load();

      await cubit.submitAnswer('Ma réponse');

      expect(repository.lastDraft, isNull);
      expect((cubit.state as QuestionDetailLoaded).answerError, isNotNull);
    });
  });
}