import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Bloc « libellé + consigne + champ » répété tout au long du formulaire.
class QuestionFormSection extends StatelessWidget {
  const QuestionFormSection({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.isRequired = true,
    this.error,
    this.trailing,
  });

  final String label;
  final String? hint;
  final bool isRequired;
  final String? error;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: theme.textTheme.titleSmall,
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: colors.error),
                      ),
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(hint!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.sm),
        child,
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topLeft,
          child: error == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs + 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: colors.error,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Expanded(
                        child: Text(
                          error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Décoration des champs du formulaire : celle du thème, bordure rouge en
/// cas d'erreur (le message est affiché par [QuestionFormSection]).
InputDecoration questionFieldDecoration({
  required ColorScheme colors,
  String? hintText,
  bool hasError = false,
}) {
  if (!hasError) return InputDecoration(hintText: hintText);
  final border = OutlineInputBorder(
    borderRadius: AppRadius.mdAll,
    borderSide: BorderSide(color: colors.error),
  );
  return InputDecoration(
    hintText: hintText,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colors.error, width: 1.6),
    ),
  );
}
