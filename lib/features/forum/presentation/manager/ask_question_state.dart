import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:equatable/equatable.dart';

class AskQuestionState extends Equatable {
  const AskQuestionState({
    this.type = QuestionType.fallback,
    this.title = '',
    this.content = '',
    this.tags = const [],
    this.status = QuestionStatus.review,
    this.showErrors = false,
    this.isSubmitting = false,
    this.error,
    this.published,
  });

  /// Longueurs minimales reprises du formulaire Stack Overflow.
  static const int titleMinLength = 15;
  static const int contentMinLength = 220;
  static const int maxTags = 5;

  final QuestionType type;
  final String title;
  final String content;
  final List<String> tags;
  final QuestionStatus status;

  /// Vrai une fois que l'utilisateur a tenté d'envoyer : les erreurs de
  /// saisie ne s'affichent pas avant.
  final bool showErrors;
  final bool isSubmitting;
  final String? error;

  /// Question créée lors du dernier envoi réussi.
  final Question? published;

  String? get titleError {
    final value = title.trim();
    if (value.isEmpty) return 'Titre requis';
    if (value.length < titleMinLength) {
      return '$titleMinLength caractères minimum';
    }
    return null;
  }

  String? get contentError {
    final value = content.trim();
    if (value.isEmpty) return 'Description requise';
    if (value.length < contentMinLength) {
      return '$contentMinLength caractères minimum';
    }
    return null;
  }

  String? get tagsError {
    if (tags.isEmpty) return 'Ajoutez au moins un tag';
    return null;
  }

  bool get isValid =>
      titleError == null && contentError == null && tagsError == null;

  bool get canAddTag => tags.length < maxTags;

  static const Object _unset = Object();

  AskQuestionState copyWith({
    QuestionType? type,
    String? title,
    String? content,
    List<String>? tags,
    QuestionStatus? status,
    bool? showErrors,
    bool? isSubmitting,
    Object? error = _unset,
    Object? published = _unset,
  }) {
    return AskQuestionState(
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      showErrors: showErrors ?? this.showErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: identical(error, _unset) ? this.error : error as String?,
      published:
          identical(published, _unset) ? this.published : published as Question?,
    );
  }

  @override
  List<Object?> get props => [
        type,
        title,
        content,
        tags,
        status,
        showErrors,
        isSubmitting,
        error,
        published,
      ];
}
