import 'dart:async';

import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_question.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/domain/usecases/update_answer.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState> {
  QuestionDetailCubit({
    required String questionId,
    required GetQuestionById getQuestionById,
    required CreateAnswer createAnswer,
    required UpdateAnswer updateAnswer,
    required DeleteAnswer deleteAnswer,
    required UpdateQuestion updateQuestion,
    required DeleteQuestion deleteQuestion,
    required QuestionRepository repository,
    required AuthGateway authGateway,
  }) : _questionId = questionId,
       _getQuestionById = getQuestionById,
       _createAnswer = createAnswer,
       _updateAnswer = updateAnswer,
       _deleteAnswer = deleteAnswer,
       _updateQuestion = updateQuestion,
       _deleteQuestion = deleteQuestion,
       _repository = repository,
       _authGateway = authGateway,
       super(const QuestionDetailInitial());

  final String _questionId;
  final GetQuestionById _getQuestionById;
  final CreateAnswer _createAnswer;
  final UpdateAnswer _updateAnswer;
  final DeleteAnswer _deleteAnswer;
  final UpdateQuestion _updateQuestion;
  final DeleteQuestion _deleteQuestion;
  final QuestionRepository _repository;
  final AuthGateway _authGateway;

  StreamSubscription<void>? _answersSubscription;

  /// Charge la question, puis s'abonne au flux temps réel de ses réponses :
  /// toute réponse ajoutée, modifiée ou supprimée (y compris par un autre
  /// utilisateur) met la liste à jour sans rechargement manuel.
  Future<void> load() async {
    emit(const QuestionDetailLoading());

    final questionResult = await _getQuestionById(_questionId);
    final question = questionResult.fold((failure) {
      emit(QuestionDetailError(failure.message));
      return null;
    }, (loaded) => loaded);
    if (question == null) return;

    emit(QuestionDetailLoaded(question: question, answers: const []));

    await _answersSubscription?.cancel();
    _answersSubscription = _repository.watchAnswers(_questionId).listen((
      result,
    ) {
      final current = state;
      if (current is! QuestionDetailLoaded) return;

      result.fold(
        (failure) => emit(current.copyWith(answerActionError: failure.message)),
        (answers) => emit(
          current.copyWith(
            answers: answers,
            question: current.question.copyWith(answersCount: answers.length),
          ),
        ),
      );
    });
  }

  Future<void> submitAnswer(String content) async {
    final current = state;
    if (current is! QuestionDetailLoaded || current.isSubmitting) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      emit(
        current.copyWith(answerError: 'Rédigez une réponse avant d’envoyer.'),
      );
      return;
    }

    final authorId = _authGateway.currentUserId;
    if (authorId == null) {
      emit(current.copyWith(answerError: 'Connectez-vous pour répondre.'));
      return;
    }

    emit(
      current.copyWith(isSubmitting: true, answerError: null, published: null),
    );
    final author = _authGateway.currentUser;
    final result = await _createAnswer(
      _questionId,
      AnswerDraft(
        content: trimmed,
        authorId: authorId,
        // ponytail: identité dénormalisée comme sur les questions.
        authorName: author?.displayName ?? author?.email,
        authorPhoto: author?.photoUrl,
      ),
    );

    final afterCall = state;
    if (afterCall is! QuestionDetailLoaded) return;

    result.fold(
      (failure) => emit(
        afterCall.copyWith(isSubmitting: false, answerError: failure.message),
      ),
      (answer) => emit(
        afterCall.copyWith(
          isSubmitting: false,
          published: answer,
          answerError: null,
        ),
      ),
    );
  }

  /// Indique quelle réponse l'utilisateur est en train d'éditer (ou `null`
  /// pour annuler l'édition en cours).
  void startEditing(String? answerId) {
    final current = state;
    if (current is! QuestionDetailLoaded) return;
    emit(current.copyWith(editingAnswerId: answerId, answerActionError: null));
  }

  /// Modifie une réponse dont l'utilisateur courant est l'auteur.
  Future<void> editAnswer(String answerId, String content) async {
    final current = state;
    if (current is! QuestionDetailLoaded) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      emit(
        current.copyWith(
          answerActionError: 'La réponse ne peut pas être vide.',
        ),
      );
      return;
    }

    if (!_isAuthorOf(answerId, current.answers)) {
      emit(
        current.copyWith(
          answerActionError:
              'Vous ne pouvez modifier que vos propres réponses.',
        ),
      );
      return;
    }

    final result = await _updateAnswer(_questionId, answerId, trimmed);

    final afterCall = state;
    if (afterCall is! QuestionDetailLoaded) return;

    result.fold(
      (failure) => emit(afterCall.copyWith(answerActionError: failure.message)),
      (_) => emit(
        afterCall.copyWith(editingAnswerId: null, answerActionError: null),
      ),
    );
  }

  /// Supprime une réponse dont l'utilisateur courant est l'auteur.
  Future<void> removeAnswer(String answerId) async {
    final current = state;
    if (current is! QuestionDetailLoaded) return;

    if (!_isAuthorOf(answerId, current.answers)) {
      emit(
        current.copyWith(
          answerActionError:
              'Vous ne pouvez supprimer que vos propres réponses.',
        ),
      );
      return;
    }

    final result = await _deleteAnswer(_questionId, answerId);

    final afterCall = state;
    if (afterCall is! QuestionDetailLoaded) return;

    result.fold(
      (failure) => emit(afterCall.copyWith(answerActionError: failure.message)),
      (_) => emit(afterCall.copyWith(answerActionError: null)),
    );
  }

  /// Vrai si l'utilisateur connecté est l'auteur de la réponse.
  ///
  /// ⚠️ Cette vérification protège l'expérience utilisateur, pas les
  /// données : la véritable protection doit venir des règles de sécurité
  /// Firestore, qui doivent interdire l'écriture d'une réponse dont
  /// `authorId` diffère de `request.auth.uid`.
  bool isOwnAnswer(Answer answer) {
    final userId = _authGateway.currentUserId;
    return userId != null && answer.authorId == userId;
  }

  /// Vrai si l'utilisateur connecté est l'auteur de la question.
  bool isOwnQuestion(Question question) {
    final userId = _authGateway.currentUserId;
    return userId != null && question.authorId == userId;
  }

  /// Remplace titre/description/tags de la question courante.
  Future<void> saveQuestion({
    required String title,
    required String content,
    required List<String> tags,
    required QuestionType type,
  }) async {
    final current = state;
    if (current is! QuestionDetailLoaded || current.isQuestionSaving) return;

    final question = current.question;
    if (!isOwnQuestion(question)) {
      emit(
        current.copyWith(
          questionActionError:
              'Vous ne pouvez modifier que vos propres questions.',
        ),
      );
      return;
    }

    emit(current.copyWith(isQuestionSaving: true, questionActionError: null));
    final result = await _updateQuestion(
      _questionId,
      QuestionDraft(
        authorId: question.authorId,
        authorName: question.authorName,
        authorPhoto: question.authorPhoto,
        title: title.trim(),
        content: content.trim(),
        type: type,
        status: question.status,
        tags: tags,
      ),
    );

    final afterCall = state;
    if (afterCall is! QuestionDetailLoaded) return;

    result.fold(
      (failure) => emit(
        afterCall.copyWith(
          isQuestionSaving: false,
          questionActionError: failure.message,
        ),
      ),
      (updated) =>
          emit(afterCall.copyWith(isQuestionSaving: false, question: updated)),
    );
  }

  /// Supprime la question courante (déclenche l'état [QuestionDetailDeleted])
  /// puis ferme l'écran dans la page.
  Future<void> deleteQuestion() async {
    final current = state;
    if (current is! QuestionDetailLoaded || current.isQuestionSaving) return;

    if (!isOwnQuestion(current.question)) {
      emit(
        current.copyWith(
          questionActionError:
              'Vous ne pouvez supprimer que vos propres questions.',
        ),
      );
      return;
    }

    emit(current.copyWith(isQuestionSaving: true, questionActionError: null));
    final result = await _deleteQuestion(_questionId);

    final afterCall = state;
    if (afterCall is! QuestionDetailLoaded) return;

    result.fold(
      (failure) => emit(
        afterCall.copyWith(
          isQuestionSaving: false,
          questionActionError: failure.message,
        ),
      ),
      (_) => emit(const QuestionDetailDeleted()),
    );
  }

  bool _isAuthorOf(String answerId, List<Answer> answers) {
    final userId = _authGateway.currentUserId;
    if (userId == null) return false;
    final matches = answers.where((a) => a.id == answerId);
    if (matches.isEmpty) return false;
    return matches.first.authorId == userId;
  }

  @override
  Future<void> close() {
    _answersSubscription?.cancel();
    return super.close();
  }
}
