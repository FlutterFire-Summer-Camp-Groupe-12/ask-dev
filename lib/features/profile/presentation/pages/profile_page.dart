import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/app_avatar.dart';
import 'package:askdev/core/widgets/app_navigation_shell.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/core/widgets/section_header.dart';
import 'package:askdev/core/widgets/skeleton.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/presentation/manager/user_activity_cubit.dart';
import 'package:askdev/features/forum/presentation/widgets/question_card.dart';
import 'package:askdev/features/profile/domain/entities/user_profile.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserActivityCubit>(
      create: (_) => sl<UserActivityCubit>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  /// L'onglet reste vivant quand on navigue : on recharge à chaque retour
  /// sur l'onglet, sinon une question publiée entre-temps n'apparaît pas.
  TabsRouter? _tabs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabs = AutoTabsRouter.of(context);
    if (!identical(_tabs, tabs)) {
      _tabs?.removeListener(_onTabsChanged);
      _tabs = tabs..addListener(_onTabsChanged);
    }
  }

  @override
  void dispose() {
    _tabs?.removeListener(_onTabsChanged);
    super.dispose();
  }

  void _onTabsChanged() {
    if (_tabs?.activeIndex == AppNavigationShellPage.profileTab) _load();
  }

  void _load() {
    final user = context.read<AuthCubit>().state.user;
    context.read<ProfileCubit>().loadProfile(
      user?.uid ?? '',
      fallbackPseudo: user?.displayName,
      fallbackEmail: user?.email,
    );
    context.read<UserActivityCubit>().load(user?.uid ?? '');
  }

  Future<void> _refresh() async {
    _load();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final profile = state.profile;
            if (profile == null) {
              return ListView(
                padding: AppLayout.listPadding(context),
                children: [
                  if (state.isLoading)
                    const SkeletonPulse(child: _ProfileHeaderSkeleton())
                  else
                    const EmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'Profil indisponible',
                      message: 'Impossible de charger votre profil.',
                    ),
                ],
              );
            }

            return ListView(
              padding: AppLayout.listPadding(context),
              children: [
                _ProfileIdentity(profile: profile),
                const SizedBox(height: AppSpacing.xl),
                const _ProfileStats(),
                const SizedBox(height: AppSpacing.lg),
                _AboutCard(profile: profile),
                const SizedBox(height: AppSpacing.xl),
                const _RecentQuestions(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AppAvatar.url(profile.avatarUrl, name: profile.pseudo, size: 88),
        const SizedBox(height: AppSpacing.md),
        Text(profile.pseudo, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          profile.email ?? '@${profile.pseudo}',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Membre depuis ${profile.createdAt.format('MMMM yyyy')}',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => context.router.root.push(const EditProfileRoute()),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Modifier le profil'),
        ),
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserActivityCubit, UserActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Row(
              children: [
                _Stat(
                  value: activity?.questionsCount,
                  label: 'Questions',
                  loading: state.isLoading,
                  onTap: () => context.router.root.push(
                    const MyContributionsRoute(),
                  ),
                ),
                const _StatDivider(),
                _Stat(
                  value: activity?.answersCount,
                  label: 'Réponses',
                  loading: state.isLoading,
                  onTap: () => context.router.root.push(
                    const MyContributionsRoute(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.loading,
    this.onTap,
  });

  final int? value;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              if (loading && value == null)
                const SkeletonPulse(child: SkeletonBox(width: 28, height: 18))
              else
                Text('${value ?? 0}', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bio = profile.bio?.trim() ?? '';
    return SectionCard(
      title: 'À propos',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bio.isEmpty ? 'Aucune bio pour le moment.' : bio,
              style: bio.isEmpty
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    )
                  : theme.textTheme.bodyMedium,
            ),
            if (profile.topics.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Topics', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              TagWrap(tags: profile.topics),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentQuestions extends StatelessWidget {
  const _RecentQuestions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserActivityCubit, UserActivityState>(
      builder: (context, state) {
        final questions = state.activity?.recentQuestions ?? const <Question>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(
              'Questions récentes',
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
            ),
            if (state.isLoading && questions.isEmpty)
              const SkeletonPulse(child: QuestionCardSkeleton())
            else if (questions.isEmpty)
              EmptyState(
                icon: Icons.forum_outlined,
                message: state.error ?? 'Vous n\'avez pas encore publié.',
                compact: true,
                action: state.error != null
                    ? null
                    : FilledButton.icon(
                        onPressed: () =>
                            context.router.root.push(const AskQuestionRoute()),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Poser une question'),
                      ),
              )
            else
              for (final question in questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: QuestionCard(
                    question: question,
                    showAuthor: false,
                    onTap: () => context.router.root.push(
                      QuestionDetailRoute(questionId: question.id),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(height: 88, circle: true),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(width: 140, height: 18),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(width: 180, height: 12),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 84, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 140, radius: AppRadius.lg),
      ],
    );
  }
}
