import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/app_avatar.dart';
import 'package:askdev/core/widgets/app_navigation_shell.dart';
import 'package:askdev/core/widgets/confirm_dialog.dart';
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

  Future<void> _signOut(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      title: 'Se déconnecter ?',
      message: 'Vous devrez saisir vos identifiants à la prochaine ouverture.',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (confirmed) await cubit.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = context.watch<AuthCubit>().state.user;
    final themeMode = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: AppLayout.listPadding(context),
        children: [
          SectionCard(
            title: 'Votre compte',
            child: ListTile(
              leading: AppAvatar.url(
                user?.photoUrl,
                name: user?.displayName ?? user?.email,
                size: 40,
              ),
              title: Text(user?.displayName ?? user?.email ?? 'Utilisateur'),
              subtitle: user?.email != null ? Text(user!.email!) : null,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
              ),
              onTap: () => AutoTabsRouter.of(
                context,
              ).setActiveIndex(AppNavigationShellPage.profileTab),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Apparence',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded, size: 18),
                      label: Text('Système'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined, size: 18),
                      label: Text('Clair'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined, size: 18),
                      label: Text('Sombre'),
                    ),
                  ],
                  selected: {themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => context
                      .read<SettingsCubit>()
                      .setThemeMode(selection.first),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Session',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: DestructiveButton(
                label: 'Se déconnecter',
                onPressed: () => _signOut(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
