import 'package:askdev/core/themes/app_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: '*',
                        style: TextStyle(color: AppColors.danger),
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
            style: const TextStyle(
              color: AppColors.textMuted,
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
              const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
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
  String? hintText,
  bool hasError = false,
  EdgeInsets contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 13),
    filled: true,
    fillColor: AppColors.surface,
    isDense: true,
    contentPadding: contentPadding,
    enabledBorder: border(
      hasError ? AppColors.danger : AppColors.border,
      1,
    ),
    focusedBorder: border(
      hasError ? AppColors.danger : AppColors.accent,
      1.6,
    ),
    disabledBorder: border(AppColors.border, 1),
    errorStyle: const TextStyle(height: 0, fontSize: 0),
  );
}
