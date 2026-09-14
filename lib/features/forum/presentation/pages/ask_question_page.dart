import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/responsive.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:askdev/features/forum/presentation/widgets/markdown_toolbar.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form_section.dart';
import 'package:askdev/features/forum/presentation/widgets/question_type_dropdown.dart';
import 'package:askdev/features/forum/presentation/widgets/tag_input_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formulaire de création d'une question, repris de la page « Ask a question »
/// de Stack Overflow : type, titre, description Markdown, tags.
@RoutePage()
class AskQuestionPage extends StatelessWidget {
  const AskQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AskQuestionCubit>(
      create: (_) => sl<AskQuestionCubit>(),
      child: const AskQuestionView(),
    );
  }
}

class AskQuestionView extends StatefulWidget {
  const AskQuestionView({super.key});

  @override
  State<AskQuestionView> createState() => _AskQuestionViewState();
}

class _AskQuestionViewState extends State<AskQuestionView> {
  static const List<String> _tagSuggestions = [
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

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, AskQuestionState state) {
    final published = state.published;
    if (published != null) {
      _titleController.clear();
      _contentController.clear();
      context.showSuccess('Question publiée. Bonne chance !');
      return;
    }
    final error = state.error;
    if (error != null) context.showError(error);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AskQuestionCubit>();
    final horizontalPadding =
        Responsive.getHorizontalMargin(context.screenSize.width) + 12;

    return BlocListener<AskQuestionCubit, AskQuestionState>(
      listenWhen: (previous, current) =>
          previous.published != current.published ||
          (current.error != null && previous.error != current.error),
      listener: _onStateChanged,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            tooltip: 'Fermer',
          ),
          title: const Text('Poser une question'),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  32,
                ),
                children: [
                  const _WritingTips(),
                  const SizedBox(height: 20),
                  _buildTypeSection(cubit),
                  const SizedBox(height: 22),
                  _buildTitleSection(cubit),
                  const SizedBox(height: 22),
                  _buildContentSection(cubit),
                  const SizedBox(height: 22),
                  _buildTagsSection(cubit),
                  const SizedBox(height: 26),
                  _buildSubmitButton(cubit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSection(AskQuestionCubit cubit) {
    return BlocBuilder<AskQuestionCubit, AskQuestionState>(
      buildWhen: (previous, current) =>
          previous.type != current.type ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return QuestionFormSection(
          label: 'Type',
          hint: state.type.description,
          child: QuestionTypeDropdown(
            value: state.type,
            onChanged: cubit.typeChanged,
            enabled: !state.isSubmitting,
          ),
        );
      },
    );
  }

  Widget _buildTitleSection(AskQuestionCubit cubit) {
    return BlocBuilder<AskQuestionCubit, AskQuestionState>(
      buildWhen: (previous, current) =>
          previous.title != current.title ||
          previous.showErrors != current.showErrors ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        final error = state.showErrors ? state.titleError : null;
        return QuestionFormSection(
          label: 'Titre',
          hint:
              'Soyez précis, comme si vous posiez la question à un collègue. '
              '${AskQuestionState.titleMinLength} caractères minimum.',
          error: error,
          trailing: _CharacterCounter(
            current: state.title.trim().length,
            minimum: AskQuestionState.titleMinLength,
          ),
          child: TextField(
            controller: _titleController,
            enabled: !state.isSubmitting,
            onChanged: cubit.titleChanged,
            textInputAction: TextInputAction.next,
            minLines: 1,
            maxLines: 2,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
              height: 1.4,
            ),
            decoration: questionFieldDecoration(
              colors: colors,
              hintText:
                  'ex. Pourquoi mon BlocProvider ne trouve pas le cubit ?',
              hasError: error != null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentSection(AskQuestionCubit cubit) {
    return BlocBuilder<AskQuestionCubit, AskQuestionState>(
      buildWhen: (previous, current) =>
          previous.content != current.content ||
          previous.showErrors != current.showErrors ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        final error = state.showErrors ? state.contentError : null;
        return QuestionFormSection(
          label: 'Description',
          hint:
              'Donnez tout ce qui est nécessaire pour vous répondre : ce que '
              'vous avez essayé, le code, le message d\'erreur. '
              '${AskQuestionState.contentMinLength} caractères minimum.',
          error: error,
          trailing: _CharacterCounter(
            current: state.content.trim().length,
            minimum: AskQuestionState.contentMinLength,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null ? colors.error : colors.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                MarkdownToolbar(
                  controller: _contentController,
                  enabled: !state.isSubmitting,
                ),
                TextField(
                  controller: _contentController,
                  enabled: !state.isSubmitting,
                  onChanged: cubit.contentChanged,
                  minLines: 9,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    hintText:
                        'Décrivez le problème, puis ce que vous attendiez…',
                    hintStyle: TextStyle(color: colors.outline, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagsSection(AskQuestionCubit cubit) {
    return BlocBuilder<AskQuestionCubit, AskQuestionState>(
      buildWhen: (previous, current) =>
          previous.tags != current.tags ||
          previous.showErrors != current.showErrors ||
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final error = state.showErrors ? state.tagsError : null;
        return QuestionFormSection(
          label: 'Tags',
          hint:
              'Jusqu\'à ${AskQuestionState.maxTags} tags pour décrire le sujet. '
              'Commencez à taper pour voir des suggestions.',
          error: error,
          trailing: Text(
            '${state.tags.length}/${AskQuestionState.maxTags}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          child: TagInputField(
            tags: state.tags,
            onTagAdded: cubit.tagAdded,
            onTagRemoved: cubit.tagRemoved,
            maxTags: AskQuestionState.maxTags,
            suggestions: _tagSuggestions,
            enabled: !state.isSubmitting,
            hasError: error != null,
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(AskQuestionCubit cubit) {
    return BlocBuilder<AskQuestionCubit, AskQuestionState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        return SizedBox(
          height: 46,
          child: FilledButton(
            onPressed: state.isSubmitting ? null : cubit.submit,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              disabledBackgroundColor: colors.primary.withValues(alpha: 0.4),
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Text(
                    'Publier la question',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }
}

/// Compteur « saisis / minimum » affiché à droite du libellé d'un champ.
class _CharacterCounter extends StatelessWidget {
  const _CharacterCounter({required this.current, required this.minimum});

  final int current;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reached = current >= minimum;
    return Text(
      '$current/$minimum',
      style: TextStyle(
        color: reached ? colors.primary : colors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

/// Rappel repliable des règles d'une bonne question.
class _WritingTips extends StatelessWidget {
  const _WritingTips();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          iconColor: colors.onSurfaceVariant,
          collapsedIconColor: colors.onSurfaceVariant,
          leading: Icon(
            Icons.lightbulb_outline,
            size: 18,
            color: colors.primary,
          ),
          title: Text(
            'Écrire une bonne question',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            _Tip('Résumez le problème dans le titre, en une phrase.'),
            _Tip(
              'Décrivez ce que vous avez déjà essayé et le résultat obtenu.',
            ),
            _Tip('Ajoutez le code minimal qui reproduit le problème.'),
            _Tip('Collez le message d\'erreur complet, pas un résumé.'),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 8),
            child: Icon(Icons.circle, size: 5, color: colors.onSurfaceVariant),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
