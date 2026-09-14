import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/widgets/destructive_button.dart';
import 'package:askdev/core/widgets/section_header.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/settings/presentation/manager/settings_cubit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = context.watch<AuthCubit>().state.user;
    final themeMode = context.watch<SettingsCubit>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _SectionCard(
              header: 'Votre compte',
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors.surfaceContainerHighest,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(Icons.person, color: colors.onSurfaceVariant)
                      : null,
                ),
                title: Text(user?.displayName ?? user?.email ?? 'Utilisateur'),
                subtitle: user?.email != null ? Text(user!.email!) : null,
                trailing: Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                ),
                onTap: () => context.router.root.push(const ProfileRoute()),
              ),
            ),
            _SectionCard(
              header: 'Apparence',
              child: SwitchListTile(
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: colors.onSurfaceVariant,
                ),
                title: const Text('Mode sombre'),
                value: themeMode == ThemeMode.dark,
                onChanged: (enabled) =>
                    context.read<SettingsCubit>().toggleDark(enabled: enabled),
              ),
            ),
            _SectionCard(
              header: 'Session',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: DestructiveButton(
                  label: 'Se déconnecter',
                  onPressed: () => context.read<AuthCubit>().signOut(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.header, required this.child});

  final String header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SectionHeader(header), child],
      ),
    );
  }
}
