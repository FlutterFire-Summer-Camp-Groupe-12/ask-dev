import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/core/utils/markdown.dart';
import 'package:equatable/equatable.dart';

class AskQuestionState extends Equatable {
  const AskQuestionState({
    this.type = QuestionType.fallback,
    this.title = '',
    this.content = '',
    this.tags = const [],
    this.showErrors = false,
    this.isSubmitting = false,
    this.error,
    this.published,
  });

  final QuestionType type;
  final String title;
  final String content;
  final List<String> tags;

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
    return null;
  }

  String? get contentError {
    final value = stripMarkdown(content).trim();
    if (value.isEmpty) return 'Description requise';
    return null;
  }

  String? get tagsError {
    if (tags.isEmpty) return 'Ajoutez au moins un tag';
    return null;
  }

  bool get isValid =>
      titleError == null && contentError == null && tagsError == null;

  /// Toujours vrai : le nombre de tags n'est plus borné.
  bool get canAddTag => true;

  static const Object _unset = Object();

  AskQuestionState copyWith({
    QuestionType? type,
    String? title,
    String? content,
    List<String>? tags,
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
      showErrors: showErrors ?? this.showErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: identical(error, _unset) ? this.error : error as String?,
      published: identical(published, _unset)
          ? this.published
          : published as Question?,
    );
  }

  @override
  List<Object?> get props => [
    type,
    title,
    content,
    tags,
    showErrors,
    isSubmitting,
    error,
    published,
  ];
}
