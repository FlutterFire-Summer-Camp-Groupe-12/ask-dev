import 'package:askdev/core/routes/app_router.dart';
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
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Réglages',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            const _SectionHeader('Votre compte'),
            ListTile(
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
              trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
              onTap: () => context.router.root.push(const ProfileRoute()),
            ),
            const Divider(height: 28),
            const _SectionHeader('Apparence'),
            SwitchListTile(
              secondary: Icon(
                Icons.dark_mode_outlined,
                color: colors.onSurfaceVariant,
              ),
              title: const Text('Mode sombre'),
              value: themeMode == ThemeMode.dark,
              onChanged: (enabled) =>
                  context.read<SettingsCubit>().toggleDark(enabled: enabled),
            ),
            const Divider(height: 28),
            const _SectionHeader('Session'),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(
                'Se déconnecter',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}