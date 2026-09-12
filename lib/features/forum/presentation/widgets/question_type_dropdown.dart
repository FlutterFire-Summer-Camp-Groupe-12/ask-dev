import 'package:askdev/core/themes/app_colors.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form_section.dart';
import 'package:flutter/material.dart';

class QuestionTypeDropdown extends StatelessWidget {
  const QuestionTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final QuestionType value;
  final ValueChanged<QuestionType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<QuestionType>(
      initialValue: value,
      onChanged: enabled
          ? (selected) {
              if (selected != null) onChanged(selected);
            }
          : null,
      isExpanded: true,
      dropdownColor: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(Icons.unfold_more, size: 18, color: AppColors.textMuted),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: questionFieldDecoration(),
      items: [
        for (final type in QuestionType.values)
          DropdownMenuItem<QuestionType>(
            value: type,
            child: Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
      ],
      selectedItemBuilder: (context) => [
        for (final type in QuestionType.values)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
