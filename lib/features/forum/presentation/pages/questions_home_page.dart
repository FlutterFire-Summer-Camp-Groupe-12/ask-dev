import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/core/routes/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_injection/injection.dart';
import '../manager/question_list_cubit.dart';
import '../manager/question_list_state.dart';
import '../widgets/question_card.dart';

@RoutePage()
class QuestionsHomePage extends StatelessWidget {
  const QuestionsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuestionListCubit>()..load(),
      child: const _QuestionsHomeView(),
    );
  }
}

class _QuestionsHomeView extends StatefulWidget {
  const _QuestionsHomeView();

  @override
  State<_QuestionsHomeView> createState() => _QuestionsHomeViewState();
}

class _QuestionsHomeViewState extends State<_QuestionsHomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuestionListCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, _) {
                  return TextField(
                    controller: _searchController,
                    onChanged: cubit.search,
                    onSubmitted: (query) => cubit.search(query, immediate: true),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Rechercher dans les questions…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Effacer',
                              onPressed: () {
                                _searchController.clear();
                                cubit.search('', immediate: true);
                              },
                            ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ),
            BlocSelector<QuestionListCubit, QuestionListState, bool>(
              selector: (state) =>
                  state.status == QuestionListStatus.loading &&
                  state.questions.isNotEmpty,
              builder: (context, refreshing) => SizedBox(
                height: 2,
                child: refreshing ? const LinearProgressIndicator() : null,
              ),
            ),
            Expanded(
              child: BlocBuilder<QuestionListCubit, QuestionListState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuestionListState state) {
    final cubit = context.read<QuestionListCubit>();

    if (state.questions.isEmpty) {
      switch (state.status) {
        case QuestionListStatus.initial:
        case QuestionListStatus.loading:
          return const Center(child: CircularProgressIndicator());
        case QuestionListStatus.failure:
          return _centered(
            EmptyState(
              icon: Icons.error_outline,
              title: 'Chargement impossible',
              message: state.error ?? 'Une erreur est survenue.',
              action: FilledButton.icon(
                onPressed: cubit.load,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
              ),
            ),
          );
        case QuestionListStatus.success:
          if (state.isSearching) {
            return _centered(
              EmptyState(
                icon: Icons.search_off,
                title: 'Aucun résultat',
                message:
                    'Aucune question ne correspond à « ${state.query.trim()} ».',
              ),
            );
          }
          return _centered(
            EmptyState(
              icon: Icons.forum_outlined,
              title: 'Aucune question pour le moment',
              message: 'Soyez le premier à lancer la discussion.',
              action: FilledButton.icon(
                onPressed: () => AutoTabsRouter.of(context).setActiveIndex(1),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Poser une question'),
              ),
            ),
          );
      }
    }

    final showFooter = state.hasMore || state.loadMoreError != null;
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: state.questions.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.questions.length) {
            return _LoadMoreFooter(
              // Nouvelle clé à chaque page : le pied de liste redemande la
              // suite s'il est encore visible après un chargement.
              key: ValueKey('${state.questions.length}-${state.nextCursor}'),
              isLoading: state.isLoadingMore,
              error: state.loadMoreError,
              onLoadMore: cubit.loadMore,
            );
          }
          final question = state.questions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: QuestionCard(
              question: question,
              onTap: () => context.router.push(
                QuestionDetailRoute(questionId: question.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _centered(Widget child) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

/// Pied de liste : déclenche la page suivante dès qu'il est construit, donc
/// dès qu'il approche de l'écran. Après un échec, il attend un appui.
class _LoadMoreFooter extends StatefulWidget {
  const _LoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onLoadMore,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onLoadMore;

  @override
  State<_LoadMoreFooter> createState() => _LoadMoreFooterState();
}

class _LoadMoreFooterState extends State<_LoadMoreFooter> {
  @override
  void initState() {
    super.initState();
    if (widget.error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onLoadMore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: error != null && !widget.isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: widget.onLoadMore,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                  ),
                ],
              )
            : const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
      ),
    );
  }
}
