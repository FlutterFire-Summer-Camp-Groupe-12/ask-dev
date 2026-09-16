import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/question_slice.dart';
import '../../domain/search/search_text.dart';
import '../../domain/usecases/get_recent_questions.dart';
import '../../domain/usecases/search_questions.dart';
import 'question_list_state.dart';

class QuestionListCubit extends Cubit<QuestionListState> {
  QuestionListCubit({
    required GetRecentQuestions getRecentQuestions,
    required SearchQuestions searchQuestions,
    this.searchDelay = const Duration(milliseconds: 350),
  }) : _getRecentQuestions = getRecentQuestions,
       _searchQuestions = searchQuestions,
       super(const QuestionListState());

  final GetRecentQuestions _getRecentQuestions;
  final SearchQuestions _searchQuestions;

  /// Attente après la dernière frappe avant d'interroger Firestore : chaque
  /// recherche coûte des lectures.
  final Duration searchDelay;

  Timer? _searchTimer;

  // Incrémenté à chaque nouvelle liste : une réponse arrivée après un
  // changement de recherche est ignorée.
  int _generation = 0;

  /// (Re)charge la première page de la recherche courante.
  Future<void> load() {
    _searchTimer?.cancel();
    return _loadFirstPage(state.query);
  }

  /// Met à jour la recherche. Le chargement part après [searchDelay], ou
  /// tout de suite si [immediate] (bouton effacer, validation au clavier).
  void search(String query, {bool immediate = false}) {
    _searchTimer?.cancel();
    if (SearchQuery.parse(query).tokens.join(' ') ==
        SearchQuery.parse(state.query).tokens.join(' ')) {
      // Seule la ponctuation ou un mot vide a changé : mêmes résultats.
      emit(state.copyWith(query: query));
      return;
    }
    if (immediate) {
      _loadFirstPage(query);
      return;
    }
    _searchTimer = Timer(searchDelay, () => _loadFirstPage(query));
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null ||
        state.isLoadingMore ||
        state.status != QuestionListStatus.success) {
      return;
    }

    final generation = _generation;
    emit(state.copyWith(isLoadingMore: true, loadMoreError: null));
    final result = await _fetch(state.query, cursor);
    if (isClosed || generation != _generation) return;

    result.match(
      (failure) => emit(
        state.copyWith(isLoadingMore: false, loadMoreError: failure.message),
      ),
      (slice) {
        final known = {for (final q in state.questions) q.id};
        emit(
          state.copyWith(
            isLoadingMore: false,
            questions: [
              ...state.questions,
              ...slice.questions.where((q) => !known.contains(q.id)),
            ],
            nextCursor: slice.nextCursor,
          ),
        );
      },
    );
  }

  Future<void> _loadFirstPage(String query) async {
    final generation = ++_generation;
    // Les questions précédentes restent visibles pendant le chargement.
    emit(
      state.copyWith(
        status: QuestionListStatus.loading,
        query: query,
        isLoadingMore: false,
        error: null,
        loadMoreError: null,
      ),
    );

    final result = await _fetch(query, null);
    if (isClosed || generation != _generation) return;

    result.match(
      (failure) => emit(
        state.copyWith(
          status: QuestionListStatus.failure,
          questions: const [],
          nextCursor: null,
          error: failure.message,
        ),
      ),
      (slice) => emit(
        state.copyWith(
          status: QuestionListStatus.success,
          questions: slice.questions,
          nextCursor: slice.nextCursor,
        ),
      ),
    );
  }

  Future<Either<Failure, QuestionSlice>> _fetch(String query, String? cursor) {
    final searchQuery = SearchQuery.parse(query);
    if (searchQuery.isEmpty) {
      return _getRecentQuestions(startAfter: cursor);
    }
    return _searchQuestions(searchQuery, startAfter: cursor);
  }

  @override
  Future<void> close() {
    _searchTimer?.cancel();
    return super.close();
  }
}
