import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Libellé discret en tête d'un bloc (« Votre compte », « Apparence »).
///
/// Jamais pour un titre de contenu : ceux-là utilisent `titleMedium`.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.label, {
    super.key,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.sm,
    ),
  });

  final String label;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(label.toUpperCase(), style: style)),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Carte regroupant un bloc de réglages ou d'informations sous un
/// [SectionHeader].
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.title, this.action});

  final String? title;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) SectionHeader(title!, action: action),
          child,
        ],
      ),
    );
  }
}
