import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    context.read<ProfileCubit>().loadProfile(
          user?.uid ?? '',
          fallbackPseudo: user?.displayName,
          fallbackEmail: user?.email,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () =>
                context.router.root.push(const EditProfileRoute()),
            icon: const Icon(Icons.edit_outlined),
            iconSize: 20,
            color: colors.onSurfaceVariant,
            tooltip: 'Modifier le profil',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            iconSize: 21,
            color: colors.onSurfaceVariant,
            tooltip: 'Plus d’options',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final profile = state.profile;
            if (profile == null) {
              return const Center(
                child: Text('Profil indisponible'),
              );
            }
            final topics = profile.topics;
            final bio = profile.bio?.trim() ?? '';
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.outlineVariant,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: colors.surfaceContainerHighest,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? Icon(
                                    Icons.person,
                                    color: colors.onSurfaceVariant,
                                    size: 38,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.pseudo,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${profile.pseudo}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Membre depuis ${profile.createdAt.format('MMMM yyyy')}',
                          style: TextStyle(
                            color: colors.outline,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Divider(color: colors.outlineVariant, height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _ProfileStat(
                        value: '0',
                        label: 'Questions',
                      ),
                      _VerticalDivider(),
                      _ProfileStat(value: '0', label: 'Réponses'),
                      _VerticalDivider(),
                      _ProfileStat(value: '0', label: 'Meilleures'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: colors.outlineVariant, height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    bio.isEmpty ? 'Aucune bio renseignée.' : bio,
                    style: TextStyle(
                      color: bio.isEmpty
                          ? colors.outline
                          : colors.onSurface,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (topics.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Topics',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 7,
                      children: [
                        for (final topic in topics) _TopicChip(label: topic),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions récentes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right),
                        iconSize: 20,
                        color: colors.onSurfaceVariant,
                        tooltip: 'Voir les questions',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: colors.onSurface, fontSize: 10),
      ),
    );
  }
}