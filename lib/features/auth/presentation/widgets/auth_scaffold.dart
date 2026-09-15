import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/brand_wordmark.dart';
import 'package:flutter/material.dart';

/// Mise en page commune aux écrans de connexion et d'inscription : logo,
/// titre, accroche, puis le formulaire.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: AppLayout.listPadding(
          context,
          maxWidth: AppLayout.formMaxWidth,
          top: AppSpacing.sm,
        ),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: BrandWordmark(height: 34),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          form,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Séparateur « ou » entre le formulaire et les fournisseurs externes.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('ou', style: theme.textTheme.labelSmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
