import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/markdown.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/forum/domain/entities/answer_with_question.dart';
import 'package:askdev/features/forum/presentation/manager/my_contributions_cubit.dart';
import 'package:askdev/features/forum/presentation/widgets/question_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class MyContributionsPage extends StatelessWidget {
  const MyContributionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MyContributionsCubit>()..load(_currentUserId(context)),
      child: const _MyContributionsView(),
    );
  }

  static String _currentUserId(BuildContext context) {
    return context.read<AuthCubit>().state.user?.uid ?? '';
  }
}

class _MyContributionsView extends StatefulWidget {
  const _MyContributionsView();

  @override
  State<_MyContributionsView> createState() => _MyContributionsViewState();
}

class _MyContributionsViewState extends State<_MyContributionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes contributions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Questions'), Tab(text: 'Réponses')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _QuestionsTab(),
          _AnswersTab(),
        ],
      ),
    );
  }
}

class _QuestionsTab extends StatelessWidget {
  const _QuestionsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyContributionsCubit, MyContributionsState>(
      builder: (context, state) {
        if (state.isLoading && state.questions.isEmpty) {
          return QuestionListSkeleton(
            padding: AppLayout.listPadding(context, top: AppSpacing.sm),
          );
        }
        if (state.questions.isEmpty) {
          return _Centered(
            EmptyState(
              icon: Icons.forum_outlined,
              title: 'Aucune question',
              message: state.error ?? 'Vous n\'avez pas encore posé de question.',
            ),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppLayout.listPadding(context, top: AppSpacing.sm),
          itemCount: state.questions.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final question = state.questions[index];
            return QuestionCard(
              question: question,
              showAuthor: false,
              onTap: () => context.router.push(
                QuestionDetailRoute(questionId: question.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _AnswersTab extends StatelessWidget {
  const _AnswersTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyContributionsCubit, MyContributionsState>(
      builder: (context, state) {
        if (state.isLoading && state.answers.isEmpty) {
          return QuestionListSkeleton(
            padding: AppLayout.listPadding(context, top: AppSpacing.sm),
          );
        }
        if (state.answers.isEmpty) {
          return _Centered(
            EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Aucune réponse',
              message: state.error ?? 'Vous n\'avez pas encore répondu.',
            ),
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppLayout.listPadding(context, top: AppSpacing.sm),
          itemCount: state.answers.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final entry = state.answers[index];
            return _AnswerCard(entry: entry);
          },
        );
      },
    );
  }
}

/// Carte d'une réponse dans la liste « Mes réponses » : la question parente
/// en titre, puis un extrait de la réponse.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.entry});

  final AnswerWithQuestion entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final excerpt = stripMarkdown(entry.answer.content);
    return Card(
      child: InkWell(
        onTap: () => context.router.push(
          QuestionDetailRoute(questionId: entry.questionId),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Réponse · ${entry.answer.createdAt.timeAgo()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                entry.questionTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(child: SingleChildScrollView(child: child));
  }
}