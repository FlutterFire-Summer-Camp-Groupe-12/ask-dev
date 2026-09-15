import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:askdev/features/forum/presentation/widgets/markdown_toolbar.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form_section.dart';
import 'package:askdev/features/forum/presentation/widgets/question_type_dropdown.dart';
import 'package:askdev/features/forum/presentation/widgets/tag_input_field.dart';
import 'package:flutter/material.dart';

/// Tags proposés pendant la saisie.
const List<String> questionTagSuggestions = [
  'flutter',
  'dart',
  'firebase',
  'firestore',
  'bloc',
  'clean-architecture',
  'android',
  'ios',
  'state-management',
  'dio',
  'auto-route',
  'get-it',
];

/// Champs d'une question : type, titre, description Markdown et tags.
///
/// Partagé par la création et la modification. Le widget ne garde aucun
/// état : les contrôleurs, les valeurs et les erreurs viennent de la page.
class QuestionFormFields extends StatelessWidget {
  const QuestionFormFields({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.titleController,
    required this.contentController,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.onTitleChanged,
    this.onContentChanged,
    this.titleError,
    this.contentError,
    this.tagsError,
    this.enabled = true,
  });

  final QuestionType type;
  final ValueChanged<QuestionType> onTypeChanged;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onContentChanged;
  final List<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final String? titleError;
  final String? contentError;
  final String? tagsError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionFormSection(
          label: 'Type',
          hint: type.description,
          child: QuestionTypeDropdown(
            value: type,
            onChanged: onTypeChanged,
            enabled: enabled,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        QuestionFormSection(
          label: 'Titre',
          hint: 'Soyez précis, comme si vous posiez la question à un collègue.',
          error: titleError,
          trailing: _CharacterCounter(
            controller: titleController,
            minimum: AskQuestionState.titleMinLength,
          ),
          child: TextField(
            controller: titleController,
            enabled: enabled,
            onChanged: onTitleChanged,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 3,
            style: theme.textTheme.bodyLarge,
            decoration: questionFieldDecoration(
              colors: colors,
              hintText:
                  'ex. Pourquoi mon BlocProvider ne trouve pas le cubit ?',
              hasError: titleError != null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        QuestionFormSection(
          label: 'Description',
          hint:
              'Ce que vous avez essayé, le code et le message d\'erreur. '
              'Le Markdown est pris en charge.',
          error: contentError,
          trailing: _CharacterCounter(
            controller: contentController,
            minimum: AskQuestionState.contentMinLength,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: contentError != null
                    ? colors.error
                    : colors.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                MarkdownToolbar(
                  controller: contentController,
                  enabled: enabled,
                ),
                TextField(
                  controller: contentController,
                  enabled: enabled,
                  onChanged: onContentChanged,
                  minLines: 8,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(AppSpacing.lg),
                    hintText:
                        'Décrivez le problème, puis ce que vous attendiez…',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        QuestionFormSection(
          label: 'Tags',
          hint:
              'Jusqu\'à ${AskQuestionState.maxTags} tags. Validez avec '
              'Entrée, un espace ou une virgule.',
          error: tagsError,
          trailing: Text(
            '${tags.length}/${AskQuestionState.maxTags}',
            style: theme.textTheme.labelSmall,
          ),
          child: TagInputField(
            tags: tags,
            onTagAdded: onTagAdded,
            onTagRemoved: onTagRemoved,
            maxTags: AskQuestionState.maxTags,
            suggestions: questionTagSuggestions,
            enabled: enabled,
            hasError: tagsError != null,
          ),
        ),
      ],
    );
  }
}

/// Compteur « saisis / minimum » qui suit le contrôleur sans reconstruire
/// le formulaire.
class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({required this.controller, required this.minimum});

  final TextEditingController controller;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final current = value.text.trim().length;
        final reached = current >= minimum;
        return Text(
          reached ? '$current' : '$current/$minimum',
          style: theme.textTheme.labelSmall?.copyWith(
            color: reached ? theme.colorScheme.primary : null,
            fontWeight: reached ? FontWeight.w600 : null,
          ),
        );
      },
    );
  }
}

/// Rappel repliable des règles d'une bonne question.
class QuestionWritingTips extends StatelessWidget {
  const QuestionWritingTips({super.key});

  static const _tips = [
    'Résumez le problème dans le titre, en une phrase.',
    'Décrivez ce que vous avez déjà essayé et le résultat obtenu.',
    'Ajoutez le code minimal qui reproduit le problème.',
    'Collez le message d\'erreur complet, pas un résumé.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      color: colors.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: colors.primaryContainer),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          leading: Icon(Icons.lightbulb_outline_rounded, color: colors.primary),
          title: Text(
            'Écrire une bonne question',
            style: theme.textTheme.titleSmall,
          ),
          children: [
            for (final tip in _tips)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 3,
                        right: AppSpacing.sm,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(tip, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Barre d'action collée en bas des formulaires plein écran.
class FormActionBar extends StatelessWidget {
  const FormActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final padding = AppLayout.listPadding(
      context,
      top: AppSpacing.md,
      bottom: AppSpacing.md,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: FilledButton.icon(
            onPressed: isBusy ? null : onPressed,
            icon: isBusy
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onSurfaceVariant,
                    ),
                  )
                : Icon(icon ?? Icons.send_rounded, size: 18),
            label: Text(label),
          ),
        ),
      ),
    );
  }
}
