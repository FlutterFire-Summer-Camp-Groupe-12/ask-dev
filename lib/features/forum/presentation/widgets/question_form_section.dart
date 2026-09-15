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
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    if (isRequired)
                      TextSpan(
                        text: '*',
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
          const SizedBox(height: 4),
          Text(
            hint!,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 8),
        child,
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: colors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error!,
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Décoration commune aux champs texte du formulaire.
InputDecoration questionFieldDecoration({
  required ColorScheme colors,
  String? hintText,
  bool hasError = false,
  EdgeInsets contentPadding = const EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 14,
  ),
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: colors.outline, fontSize: 13),
    filled: true,
    fillColor: colors.surfaceContainerHighest,
    isDense: true,
    contentPadding: contentPadding,
    enabledBorder: border(hasError ? colors.error : colors.outlineVariant, 1),
    focusedBorder: border(hasError ? colors.error : colors.primary, 1.6),
    disabledBorder: border(colors.outlineVariant, 1),
    errorStyle: const TextStyle(height: 0, fontSize: 0),
  );
}
