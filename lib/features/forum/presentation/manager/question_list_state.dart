import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

enum QuestionListStatus { initial, loading, success, failure }

class QuestionListState extends Equatable {
  const QuestionListState({
    this.status = QuestionListStatus.initial,
    this.query = '',
    this.questions = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.error,
    this.loadMoreError,
  });

  final QuestionListStatus status;

  /// Recherche affichée. Vide pour le fil public.
  final String query;
  final List<Question> questions;
  final String? nextCursor;
  final bool isLoadingMore;

  /// Échec du chargement de la première page.
  final String? error;

  /// Échec d'une page suivante : la liste déjà chargée reste affichée.
  final String? loadMoreError;

  bool get hasMore => nextCursor != null;

  bool get isSearching => query.trim().isNotEmpty;

  static const Object _unset = Object();

  QuestionListState copyWith({
    QuestionListStatus? status,
    String? query,
    List<Question>? questions,
    Object? nextCursor = _unset,
    bool? isLoadingMore,
    Object? error = _unset,
    Object? loadMoreError = _unset,
  }) {
    return QuestionListState(
      status: status ?? this.status,
      query: query ?? this.query,
      questions: questions ?? this.questions,
      nextCursor: identical(nextCursor, _unset)
          ? this.nextCursor
          : nextCursor as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _unset) ? this.error : error as String?,
      loadMoreError: identical(loadMoreError, _unset)
          ? this.loadMoreError
          : loadMoreError as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    questions,
    nextCursor,
    isLoadingMore,
    error,
    loadMoreError,
  ];
}
