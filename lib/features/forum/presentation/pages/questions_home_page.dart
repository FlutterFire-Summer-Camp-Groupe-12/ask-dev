import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/widgets/brand_wordmark.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Le bouton flottant se replie en icône quand on descend dans la liste.
  bool _fabExtended = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final cubit = context.read<QuestionListCubit>();
    // Le formulaire est une route racine : il s'ouvre par-dessus la barre
    // de navigation, pas dans l'onglet.
    final published = await context.router.root.push<Question>(
      const AskQuestionRoute(),
    );
    if (published == null || !mounted) return;
    context.showSuccess('Question publiée.');
    cubit.load();
  }

  bool _onScroll(UserScrollNotification notification) {
    final extended = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _fabExtended,
    };
    if (extended != _fabExtended) setState(() => _fabExtended = extended);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuestionListCubit>();
    final header = AppLayout.listPadding(context, top: 0, bottom: 0);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: header.left,
        title: const BrandWordmark(height: 30),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _askQuestion,
        isExtended: _fabExtended,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Poser une question'),
        tooltip: _fabExtended ? null : 'Poser une question',
      ),
      body: Column(
        children: [
          Padding(
            padding: header.copyWith(top: AppSpacing.xs, bottom: AppSpacing.sm),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return SearchBar(
                  controller: _searchController,
                  onChanged: cubit.search,
                  onSubmitted: (query) => cubit.search(query, immediate: true),
                  hintText: 'Rechercher dans les questions',
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    context.colors.surfaceContainerLow,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: context.colors.outlineVariant),
                  ),
                  shape: const WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  ),
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  ),
                  textStyle: WidgetStatePropertyAll(
                    context.textTheme.bodyMedium,
                  ),
                  hintStyle: WidgetStatePropertyAll(
                    context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    if (value.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Effacer',
                        onPressed: () {
                          _searchController.clear();
                          cubit.search('', immediate: true);
                        },
                      ),
                  ],
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
            child: NotificationListener<UserScrollNotification>(
              onNotification: _onScroll,
              child: BlocBuilder<QuestionListCubit, QuestionListState>(
                builder: (context, state) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildBody(context, state),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuestionListState state) {
    final cubit = context.read<QuestionListCubit>();

    if (state.questions.isEmpty) {
      switch (state.status) {
        case QuestionListStatus.initial:
        case QuestionListStatus.loading:
          return QuestionListSkeleton(
            key: const ValueKey('skeleton'),
            padding: AppLayout.listPadding(context, top: AppSpacing.sm),
          );
        case QuestionListStatus.failure:
          return _centered(
            EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Chargement impossible',
              message: state.error ?? 'Une erreur est survenue.',
              action: FilledButton.icon(
                onPressed: cubit.load,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
              ),
            ),
          );
        case QuestionListStatus.success:
          if (state.isSearching) {
            return _centered(
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucun résultat',
                message:
                    'Aucune question ne correspond à « ${state.query.trim()} ». '
                    'Essayez un autre mot, ou posez la question.',
              ),
            );
          }
          return _centered(
            EmptyState(
              icon: Icons.forum_outlined,
              title: 'Aucune question pour le moment',
              message: 'Soyez le premier à lancer la discussion.',
              action: FilledButton.icon(
                onPressed: _askQuestion,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Poser une question'),
              ),
            ),
          );
      }
    }

    final showFooter = state.hasMore || state.loadMoreError != null;
    return RefreshIndicator(
      key: const ValueKey('list'),
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        // Place pour le bouton flottant sous la dernière carte.
        padding: AppLayout.listPadding(context, top: AppSpacing.sm, bottom: 96),
        itemCount: state.questions.length + (showFooter ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
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
          return QuestionCard(
            question: question,
            onTap: () => context.router.push(
              QuestionDetailRoute(questionId: question.id),
            ),
          );
        },
      ),
    );
  }

  Widget _centered(Widget child) {
    return Center(
      key: ValueKey(child.hashCode),
      child: SingleChildScrollView(child: child),
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
    if (error != null && !widget.isLoading) {
      return Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: widget.onLoadMore,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Réessayer'),
          ),
        ],
      );
    }
    return const QuestionCardSkeleton();
  }
}
