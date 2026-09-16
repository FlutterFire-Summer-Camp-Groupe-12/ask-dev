import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:equatable/equatable.dart';

sealed class QuestionDetailState extends Equatable {
  const QuestionDetailState();

  @override
  List<Object?> get props => [];
}

class QuestionDetailInitial extends QuestionDetailState {
  const QuestionDetailInitial();
}

class QuestionDetailLoading extends QuestionDetailState {
  const QuestionDetailLoading();
}

class QuestionDetailError extends QuestionDetailState {
  const QuestionDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// La question a été supprimée : l'écran doit se fermer.
class QuestionDetailDeleted extends QuestionDetailState {
  const QuestionDetailDeleted();
}

class QuestionDetailLoaded extends QuestionDetailState {
  const QuestionDetailLoaded({
    required this.question,
    required this.answers,
    this.isSubmitting = false,
    this.answerError,
    this.published,
    this.editingAnswerId,
    this.answerActionError,
    this.isQuestionSaving = false,
    this.questionActionError,
  });

  final Question question;
  final List<Answer> answers;
  final bool isSubmitting;

  /// Message d'erreur du dernier envoi de réponse (réinitialisé à chaque
  /// nouvelle tentative).
  final String? answerError;

  /// Réponse créée lors du dernier envoi réussi, pour réagir (snackbar,
  /// nettoyage du champ).
  final Answer? published;

  /// Id de la réponse actuellement en cours d'édition dans l'UI (null si
  /// aucune édition en cours). Permet à l'écran de savoir quel champ
  /// afficher en mode édition.
  final String? editingAnswerId;

  /// Message d'erreur de la dernière tentative de modification/suppression
  /// d'une réponse (distinct de [answerError], qui concerne l'envoi d'une
  /// nouvelle réponse).
  final String? answerActionError;

  /// Édition/suppression de la question en cours (bouton désactivé).
  final bool isQuestionSaving;

  /// Message d'erreur de la dernière modification/suppression de la question.
  final String? questionActionError;

  QuestionDetailLoaded copyWith({
    Question? question,
    List<Answer>? answers,
    bool? isSubmitting,
    Object? answerError = _unset,
    Object? published = _unset,
    Object? editingAnswerId = _unset,
    Object? answerActionError = _unset,
    bool? isQuestionSaving,
    Object? questionActionError = _unset,
  }) {
    return QuestionDetailLoaded(
      question: question ?? this.question,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      answerError: identical(answerError, _unset)
          ? this.answerError
          : answerError as String?,
      published: identical(published, _unset)
          ? this.published
          : published as Answer?,
      editingAnswerId: identical(editingAnswerId, _unset)
          ? this.editingAnswerId
          : editingAnswerId as String?,
      answerActionError: identical(answerActionError, _unset)
          ? this.answerActionError
          : answerActionError as String?,
      isQuestionSaving: isQuestionSaving ?? this.isQuestionSaving,
      questionActionError: identical(questionActionError, _unset)
          ? this.questionActionError
          : questionActionError as String?,
    );
  }

  static const Object _unset = Object();

  @override
  List<Object?> get props => [
    question,
    answers,
    isSubmitting,
    answerError,
    published,
    editingAnswerId,
    answerActionError,
    isQuestionSaving,
    questionActionError,
  ];
}
