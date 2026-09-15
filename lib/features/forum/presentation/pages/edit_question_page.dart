import 'dart:async';

import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/responsive.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:askdev/features/forum/presentation/widgets/markdown_toolbar.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form_section.dart';
import 'package:askdev/features/forum/presentation/widgets/question_type_dropdown.dart';
import 'package:askdev/features/forum/presentation/widgets/tag_input_field.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Édition d'une question existante : même formulaire que la création,
/// pré-rempli depuis la question chargée. Poppe avec la question mise à jour.
@RoutePage()
class EditQuestionPage extends StatefulWidget {
  const EditQuestionPage({super.key, required this.question});

  final Question question;

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
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

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late QuestionType _type;
  late List<String> _tags;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question.title);
    _contentController = TextEditingController(text: widget.question.content);
    _type = widget.question.type;
    _tags = List.of(widget.question.tags);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.length < AskQuestionState.titleMinLength ||
        content.length < AskQuestionState.contentMinLength) {
      context.showError(
        'Titre et description doivent remplir les minimums requis.',
      );
      return;
    }

    setState(() => _isSaving = true);
    final question = widget.question;
    final result = await sl<UpdateQuestion>()(
      question.id,
      QuestionDraft(
        authorId: question.authorId,
        authorName: question.authorName,
        authorPhoto: question.authorPhoto,
        title: title,
        content: content,
        type: _type,
        status: question.status,
        tags: _tags,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) => context.showError(failure.message),
      (updated) => context.router.pop(updated),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final horizontalPadding =
        Responsive.getHorizontalMargin(context.screenSize.width) + 12;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la question'),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save,
            tooltip: 'Enregistrer',
            icon: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
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
                QuestionFormSection(
                  label: 'Type',
                  hint: _type.description,
                  child: QuestionTypeDropdown(
                    value: _type,
                    onChanged: (value) => setState(() => _type = value),
                    enabled: !_isSaving,
                  ),
                ),
                const SizedBox(height: 22),
                QuestionFormSection(
                  label: 'Titre',
                  hint:
                      'Soyez précis, comme si vous posiez la question à un '
                      'collègue. Minimum ${AskQuestionState.titleMinLength} caractères.',
                  child: TextField(
                    controller: _titleController,
                    enabled: !_isSaving,
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
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                QuestionFormSection(
                  label: 'Description',
                  hint:
                      'Donnez tout ce qui est nécessaire pour vous répondre. '
                      'Minimum ${AskQuestionState.contentMinLength} caractères.',
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        MarkdownToolbar(
                          controller: _contentController,
                          enabled: !_isSaving,
                        ),
                        TextField(
                          controller: _contentController,
                          enabled: !_isSaving,
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
                            hintStyle: TextStyle(
                              color: colors.outline,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                QuestionFormSection(
                  label: 'Tags',
                  hint:
                      'Jusqu\'à ${AskQuestionState.maxTags} tags pour décrire '
                      'le sujet. Commencez à taper pour voir des suggestions.',
                  child: TagInputField(
                    tags: _tags,
                    onTagAdded: (tag) {
                      setState(() {
                        if (!_tags.contains(tag) &&
                            _tags.length < AskQuestionState.maxTags) {
                          _tags.add(tag);
                        }
                      });
                    },
                    onTagRemoved: (tag) {
                      setState(() => _tags.remove(tag));
                    },
                    maxTags: AskQuestionState.maxTags,
                    suggestions: _tagSuggestions,
                    enabled: !_isSaving,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Enregistrer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
