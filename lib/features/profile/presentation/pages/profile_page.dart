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
            color: Colors.black54,
            tooltip: 'Modifier le profil',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            iconSize: 21,
            color: Colors.black54,
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
            final skills = profile.skills;
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
                            border: Border.all(color: Colors.black12),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: profile.avatarUrl != null
                                ? NetworkImage(profile.avatarUrl!)
                                : null,
                            child: profile.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                    size: 38,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.pseudo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${profile.pseudo}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Membre depuis ${profile.createdAt.format('MMMM yyyy')}',
                          style: const TextStyle(color: Colors.black38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Expanded(child: _ProfileStat(value: '0', label: 'Questions')),
                      _VerticalDivider(),
                      Expanded(child: _ProfileStat(value: '0', label: 'Réponses')),
                      _VerticalDivider(),
                      Expanded(child: _ProfileStat(value: '0', label: 'Meilleures')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'À propos',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    bio.isEmpty ? 'Aucune bio renseignée.' : bio,
                    style: TextStyle(
                      color: bio.isEmpty ? Colors.black38 : Colors.black87,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (skills.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Compétences',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 7,
                      children: [
                        for (final skill in skills) _SkillChip(label: skill),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Questions récentes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right),
                        iconSize: 20,
                        color: Colors.black45,
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 10),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.black12);
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black87, fontSize: 10),
      ),
    );
  }
}