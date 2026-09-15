import 'dart:async';

import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_answer.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/domain/usecases/update_answer.dart';
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

Answer _answer(String id, {String authorId = 'u1', String content = 'Réponse'}) {
  return Answer(
    id: id,
    content: '$content $id',
    authorId: authorId,
    createdAt: _now.add(Duration(hours: id.hashCode % 5)),
    updatedAt: _now,
  );
}

class _FakeQuestionRepository implements QuestionRepository {
  _FakeQuestionRepository({
    this.question,
    List<Answer> answers = const [],
    this.questionFailure,
    this.answerFailure,
    this.updateFailure,
    this.deleteFailure,
  }) : _answersController = StreamController<Either<Failure, List<Answer>>>.broadcast() {
    _answers = List.of(answers);
  }

  final Question? question;
  final Failure? questionFailure;
  final Failure? answerFailure;
  final Failure? updateFailure;
  final Failure? deleteFailure;

  late List<Answer> _answers;
  final StreamController<Either<Failure, List<Answer>>> _answersController;

  AnswerDraft? lastDraft;
  String? lastQuestionId;
  String? lastUpdatedAnswerId;
  String? lastUpdatedContent;
  String? lastDeletedAnswerId;

  void _emitAnswers() => _answersController.add(right(List.of(_answers)));

  @override
  Future<Either<Failure, Question>> getQuestionById(String id) async {
    final failure = questionFailure;
    if (failure != null) return left(failure);
    return right(question!);
  }

  @override
  Future<Either<Failure, List<Answer>>> getAnswers(String questionId) async {
    return right(_answers);
  }

  @override
  Stream<Either<Failure, List<Answer>>> watchAnswers(String questionId) {
    // Émet l'état courant dès l'abonnement, comme le ferait Firestore.
    Future.microtask(_emitAnswers);
    return _answersController.stream;
  }

  @override
  Future<Either<Failure, Question>> createQuestion(QuestionDraft draft) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Question>>> getRecentQuestions() async {
    return right(<Question>[question ?? _question()]);
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
    final answer = _answer('a-new', authorId: draft.authorId, content: draft.content);
    _answers = [..._answers, answer];
    _emitAnswers();
    return right(answer);
  }

  @override
  Future<Either<Failure, Answer>> updateAnswer(
    String questionId,
    String answerId,
    String content,
  ) async {
    lastUpdatedAnswerId = answerId;
    lastUpdatedContent = content;
    final failure = updateFailure;
    if (failure != null) return left(failure);

    final index = _answers.indexWhere((a) => a.id == answerId);
    final updated = Answer(
      id: answerId,
      content: content,
      authorId: _answers[index].authorId,
      createdAt: _answers[index].createdAt,
      updatedAt: _now,
    );
    _answers = [
      for (final a in _answers) if (a.id == answerId) updated else a,
    ];
    _emitAnswers();
    return right(updated);
  }

  @override
  Future<Either<Failure, Unit>> deleteAnswer(
    String questionId,
    String answerId,
  ) async {
    lastDeletedAnswerId = answerId;
    final failure = deleteFailure;
    if (failure != null) return left(failure);

    _answers = _answers.where((a) => a.id != answerId).toList();
    _emitAnswers();
    return right(unit);
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
    createAnswer: CreateAnswer(repository),
    updateAnswer: UpdateAnswer(repository),
    deleteAnswer: DeleteAnswer(repository),
    repository: repository,
    authGateway: _FakeAuthGateway(userId),
  );
}

void main() {
  group('QuestionDetailCubit load', () {
    test('charge la question et s’abonne aux réponses en temps réel', () async {
      final cubit = _buildCubit(
        _FakeQuestionRepository(question: _question(), answers: [_answer('a1')]),
      );

      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      expect(state, isA<QuestionDetailLoaded>());
      final loaded = state as QuestionDetailLoaded;
      expect(loaded.question.id, 'q1');
      expect(loaded.answers, hasLength(1));
    });

    test('émet une erreur quand la question est introuvable', () async {
      final cubit = _buildCubit(
        _FakeQuestionRepository(
          questionFailure: const ServerFailure(message: 'Question inexistante'),
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
      await Future<void>.delayed(Duration.zero);

      await cubit.submitAnswer('   ');

      expect(repository.lastDraft, isNull);
      expect((cubit.state as QuestionDetailLoaded).answerError, isNotNull);
    });

    test('envoie un brouillon nettoyé et publie la réponse', () async {
      final repository = _FakeQuestionRepository(question: _question());
      final cubit = _buildCubit(repository);
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.submitAnswer('   Voici ma réponse.  ');
      await Future<void>.delayed(Duration.zero);

      expect(repository.lastQuestionId, 'q1');
      expect(repository.lastDraft?.content, 'Voici ma réponse.');
      expect(repository.lastDraft?.authorId, 'u1');
      final state = cubit.state as QuestionDetailLoaded;
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
      await Future<void>.delayed(Duration.zero);

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
      await Future<void>.delayed(Duration.zero);

      await cubit.submitAnswer('Ma réponse');

      expect(repository.lastDraft, isNull);
      expect((cubit.state as QuestionDetailLoaded).answerError, isNotNull);
    });
  });

  group('QuestionDetailCubit editAnswer', () {
    test('modifie une réponse dont on est l’auteur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'u1')],
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.editAnswer('a1', 'Contenu modifié');
      await Future<void>.delayed(Duration.zero);

      expect(repository.lastUpdatedAnswerId, 'a1');
      expect(repository.lastUpdatedContent, 'Contenu modifié');
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerActionError, isNull);
    });

    test('refuse de modifier la réponse d’un autre utilisateur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'quelquun-dautre')],
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.editAnswer('a1', 'Contenu modifié');

      expect(repository.lastUpdatedAnswerId, isNull);
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerActionError, isNotNull);
    });
  });

  group('QuestionDetailCubit removeAnswer', () {
    test('supprime une réponse dont on est l’auteur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'u1')],
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.removeAnswer('a1');
      await Future<void>.delayed(Duration.zero);

      expect(repository.lastDeletedAnswerId, 'a1');
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answers, isEmpty);
    });

    test('refuse de supprimer la réponse d’un autre utilisateur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'quelquun-dautre')],
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.removeAnswer('a1');

      expect(repository.lastDeletedAnswerId, isNull);
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerActionError, isNotNull);
      expect(state.answers, hasLength(1));
    });
  });
}