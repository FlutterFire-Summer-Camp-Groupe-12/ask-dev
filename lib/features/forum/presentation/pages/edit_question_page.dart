import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Édition d'une question existante : même formulaire que la création,
/// pré-rempli depuis la question chargée. Se ferme avec la question mise à
/// jour.
@RoutePage()
class EditQuestionPage extends StatefulWidget {
  const EditQuestionPage({super.key, required this.question});

  final Question question;

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late QuestionType _type;
  late List<String> _tags;
  bool _isSaving = false;
  bool _showErrors = false;

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

  String? get _titleError {
    final length = _titleController.text.trim().length;
    if (length == 0) return 'Titre requis';
    if (length < AskQuestionState.titleMinLength) {
      return '${AskQuestionState.titleMinLength} caractères minimum';
    }
    return null;
  }

  String? get _contentError {
    final length = _contentController.text.trim().length;
    if (length == 0) return 'Description requise';
    if (length < AskQuestionState.contentMinLength) {
      return '${AskQuestionState.contentMinLength} caractères minimum';
    }
    return null;
  }

  String? get _tagsError => _tags.isEmpty ? 'Ajoutez au moins un tag' : null;

  void _addTag(String value) {
    final tag = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9+#.\-]'), '');
    if (tag.isEmpty ||
        _tags.contains(tag) ||
        _tags.length >= AskQuestionState.maxTags) {
      return;
    }
    setState(() => _tags.add(tag));
  }

  Future<void> _save() async {
    if (_titleError != null || _contentError != null || _tagsError != null) {
      setState(() => _showErrors = true);
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
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fermer',
        ),
        title: const Text('Modifier la question'),
      ),
      bottomNavigationBar: FormActionBar(
        label: 'Enregistrer',
        icon: Icons.check_rounded,
        onPressed: _save,
        isBusy: _isSaving,
      ),
      body: ListView(
        padding: AppLayout.listPadding(context),
        children: [
          QuestionFormFields(
            type: _type,
            onTypeChanged: (value) => setState(() => _type = value),
            titleController: _titleController,
            onTitleChanged: _showErrors ? (_) => setState(() {}) : null,
            contentController: _contentController,
            onContentChanged: _showErrors ? (_) => setState(() {}) : null,
            tags: _tags,
            onTagAdded: _addTag,
            onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
            titleError: _showErrors ? _titleError : null,
            contentError: _showErrors ? _contentError : null,
            tagsError: _showErrors ? _tagsError : null,
            enabled: !_isSaving,
          ),
        ],
      ),
    );
  }
}
