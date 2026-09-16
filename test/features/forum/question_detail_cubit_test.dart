import 'dart:async';

import 'package:askdev/core/error/failure.dart';
import 'package:askdev/core/session/auth_status.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/auth/domain/entities/auth_user.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_slice.dart';
import 'package:askdev/features/forum/domain/entities/user_activity.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_question.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/domain/usecases/update_answer.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

final _now = DateTime(2026, 9, 1, 12);

Question _question({int answersCount = 0, String authorId = 'u0'}) {
  return Question(
    id: 'q1',
    title: 'Comment état vide sur une liste ?',
    content: 'J’aimerais afficher un empty state.',
    authorId: authorId,
    createdAt: _now,
    updatedAt: _now,
    answersCount: answersCount,
    searchKeywords: const [],
  );
}

Answer _answer(
  String id, {
  String authorId = 'u1',
  String content = 'Réponse',
}) {
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
    this.questionUpdateFailure,
    this.questionDeleteFailure,
    this.updateResult,
  }) : _answersController =
           StreamController<Either<Failure, List<Answer>>>.broadcast() {
    _answers = List.of(answers);
  }

  final Question? question;
  final Failure? questionFailure;
  final Failure? answerFailure;
  final Failure? updateFailure;
  final Failure? deleteFailure;
  final Failure? questionUpdateFailure;
  final Failure? questionDeleteFailure;
  Question? updateResult;

  late List<Answer> _answers;
  final StreamController<Either<Failure, List<Answer>>> _answersController;

  AnswerDraft? lastDraft;
  String? lastQuestionId;
  String? lastUpdatedAnswerId;
  String? lastUpdatedContent;
  String? lastDeletedAnswerId;
  QuestionDraft? lastQuestionUpdateDraft;
  String? lastDeletedQuestionId;

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
    final answer = _answer(
      'a-new',
      authorId: draft.authorId,
      content: draft.content,
    );
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
      for (final a in _answers)
        if (a.id == answerId) updated else a,
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

  @override
  Future<Either<Failure, Question>> updateQuestion(
    String questionId,
    QuestionDraft draft,
  ) async {
    lastQuestionUpdateDraft = draft;
    final failure = questionUpdateFailure;
    if (failure != null) return left(failure);
    return right(updateResult ?? question!);
  }

  @override
  Future<Either<Failure, Unit>> deleteQuestion(String questionId) async {
    lastDeletedQuestionId = questionId;
    final failure = questionDeleteFailure;
    if (failure != null) return left(failure);
    return right(unit);
  }

  @override
  Future<Either<Failure, UserActivity>> getUserActivity(
    String userId, {
    int recentLimit = 5,
  }) => throw UnimplementedError();
}

class _FakeAuthGateway implements AuthGateway {
  _FakeAuthGateway(this.currentUserId, {this.user});

  @override
  final String? currentUserId;

  final AuthUser? user;

  @override
  AuthUser? get currentUser => user;

  @override
  AuthStatus get status => currentUserId == null
      ? AuthStatus.unauthenticated
      : AuthStatus.authenticated;

  @override
  Stream<AuthStatus> get statusStream => Stream.value(status);
}

QuestionDetailCubit _buildCubit(
  _FakeQuestionRepository repository, {
  String? userId = 'u1',
  AuthUser? user,
}) {
  return QuestionDetailCubit(
    questionId: 'q1',
    getQuestionById: GetQuestionById(repository),
    createAnswer: CreateAnswer(repository),
    updateAnswer: UpdateAnswer(repository),
    deleteAnswer: DeleteAnswer(repository),
    updateQuestion: UpdateQuestion(repository),
    deleteQuestion: DeleteQuestion(repository),
    repository: repository,
    authGateway: _FakeAuthGateway(userId, user: user),
  );
}

void main() {
  group('QuestionDetailCubit load', () {
    test('charge la question et s’abonne aux réponses en temps réel', () async {
      final cubit = _buildCubit(
        _FakeQuestionRepository(
          question: _question(),
          answers: [_answer('a1')],
        ),
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

    test(
      'conserve les réponses existantes et affiche le message d’échec',
      () async {
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
      },
    );

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

    test('affiche le message d’échec de la modification', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'u1')],
        updateFailure: const ServerFailure(message: 'Échec de la modification'),
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.editAnswer('a1', 'Contenu modifié');

      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerActionError, 'Échec de la modification');
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

    test('affiche le message d’échec de la suppression', () async {
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'u1')],
        deleteFailure: const ServerFailure(message: 'Échec de la suppression'),
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.removeAnswer('a1');

      final state = cubit.state as QuestionDetailLoaded;
      expect(state.answerActionError, 'Échec de la suppression');
      expect(state.answers, hasLength(1));
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

  group('QuestionDetailCubit saveQuestion', () {
    test('met à jour une question dont on est l’auteur', () async {
      final updated = Question(
        id: 'q1',
        title: 'Titre modifié',
        content: 'Contenu modifié.',
        authorId: 'u0',
        createdAt: _now,
        updatedAt: _now,
        answersCount: 1,
        searchKeywords: const [],
      );
      final repository = _FakeQuestionRepository(
        question: _question(),
        answers: [_answer('a1', authorId: 'u1')],
        updateResult: updated,
      );
      final cubit = _buildCubit(
        repository,
        userId: 'u0',
        user: AuthUser(
          uid: 'u0',
          email: 'alice@example.com',
          displayName: 'Alice',
          photoUrl: 'https://example.com/a.png',
        ),
      );
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.saveQuestion(
        title: 'Titre modifié',
        content: 'Contenu modifié.',
        tags: const ['flutter'],
        type: updated.type,
      );

      final state = cubit.state as QuestionDetailLoaded;
      expect(state.question.title, 'Titre modifié');
      expect(repository.lastQuestionUpdateDraft?.authorId, 'u0');
    });

    test('refuse de modifier la question d’un autre utilisateur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(authorId: 'quelquun-dautre'),
        answers: [_answer('a1', authorId: 'u1')],
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.saveQuestion(
        title: 'Titre modifié',
        content: 'Contenu modifié.',
        tags: const [],
        type: repository.question!.type,
      );

      expect(repository.lastQuestionUpdateDraft, isNull);
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.questionActionError, isNotNull);
    });

    test('relance la liste après suppression de la question', () async {
      final repository = _FakeQuestionRepository(question: _question());
      final cubit = _buildCubit(repository, userId: 'u0');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.deleteQuestion();

      expect(cubit.state, isA<QuestionDetailDeleted>());
    });

    test('refuse de supprimer la question d’un autre utilisateur', () async {
      final repository = _FakeQuestionRepository(
        question: _question(authorId: 'quelquun-dautre'),
      );
      final cubit = _buildCubit(repository, userId: 'u1');
      await cubit.load();
      await Future<void>.delayed(Duration.zero);

      await cubit.deleteQuestion();

      expect(cubit.state, isNot(isA<QuestionDetailDeleted>()));
      expect(repository.lastDeletedQuestionId, isNull);
      final state = cubit.state as QuestionDetailLoaded;
      expect(state.questionActionError, isNotNull);
    });

    test(
      'affiche le message d’échec de la modification de la question',
      () async {
        final repository = _FakeQuestionRepository(
          question: _question(),
          questionUpdateFailure: const ServerFailure(
            message: 'Échec de la question',
          ),
        );
        final cubit = _buildCubit(repository, userId: 'u0');
        await cubit.load();
        await Future<void>.delayed(Duration.zero);

        await cubit.saveQuestion(
          title: 'Titre modifié',
          content: 'Contenu modifié.',
          tags: const [],
          type: repository.question!.type,
        );

        final state = cubit.state as QuestionDetailLoaded;
        expect(state.questionActionError, 'Échec de la question');
      },
    );

    test(
      'affiche le message d’échec de la suppression de la question',
      () async {
        final repository = _FakeQuestionRepository(
          question: _question(),
          questionDeleteFailure: const ServerFailure(
            message: 'Suppression impossible',
          ),
        );
        final cubit = _buildCubit(repository, userId: 'u0');
        await cubit.load();
        await Future<void>.delayed(Duration.zero);

        await cubit.deleteQuestion();

        expect(cubit.state, isNot(isA<QuestionDetailDeleted>()));
        final state = cubit.state as QuestionDetailLoaded;
        expect(state.questionActionError, 'Suppression impossible');
      },
    );
  });
}
