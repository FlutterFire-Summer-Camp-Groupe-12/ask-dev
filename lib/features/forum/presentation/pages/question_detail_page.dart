import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/author_info.dart';
import 'package:askdev/core/widgets/markdown/app_markdown.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_question.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/domain/usecases/update_answer.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class QuestionDetailPage extends StatelessWidget {
  const QuestionDetailPage({super.key, required this.questionId});

  final String questionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuestionDetailCubit(
        questionId: questionId,
        getQuestionById: sl<GetQuestionById>(),
        createAnswer: sl<CreateAnswer>(),
        updateAnswer: sl<UpdateAnswer>(),
        deleteAnswer: sl<DeleteAnswer>(),
        updateQuestion: sl<UpdateQuestion>(),
        deleteQuestion: sl<DeleteQuestion>(),
        repository: sl<QuestionRepository>(),
        authGateway: sl<AuthGateway>(),
      )..load(),
      child: const _QuestionDetailView(),
    );
  }
}

class _QuestionDetailView extends StatefulWidget {
  const _QuestionDetailView();

  @override
  State<_QuestionDetailView> createState() => _QuestionDetailViewState();
}

class _QuestionDetailViewState extends State<_QuestionDetailView> {
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit(QuestionDetailCubit cubit) {
    if (_answerController.text.trim().isNotEmpty) {
      cubit.submitAnswer(_answerController.text);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    QuestionDetailCubit cubit,
    String answerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette réponse ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.removeAnswer(answerId);
    }
  }

  Future<void> _confirmDeleteQuestion(
    BuildContext context,
    QuestionDetailCubit cubit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette question ?'),
        content: const Text(
          'La question et toutes ses réponses seront supprimées. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.deleteQuestion();
    }
  }

  Future<void> _editQuestion(BuildContext context, Question question) async {
    final updated = await context.router.push<Question>(
      EditQuestionRoute(question: question),
    );
    if (updated != null && context.mounted) {
      // Recharge la question modifiée (contenu, tags, type) depuis Firestore.
      context.read<QuestionDetailCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<QuestionDetailCubit>();
    return BlocListener<QuestionDetailCubit, QuestionDetailState>(
      listenWhen: (previous, current) {
        if (current is QuestionDetailDeleted) return true;
        if (previous is! QuestionDetailLoaded ||
            current is! QuestionDetailLoaded) {
          return false;
        }
        return previous.published != current.published ||
            (current.answerError != null &&
                previous.answerError != current.answerError) ||
            (current.answerActionError != null &&
                previous.answerActionError != current.answerActionError) ||
            (current.questionActionError != null &&
                previous.questionActionError != current.questionActionError);
      },
      listener: (context, state) {
        if (state is QuestionDetailDeleted) {
          context.showSuccess('Question supprimée.');
          context.router.maybePop();
          return;
        }
        if (state is! QuestionDetailLoaded) return;
        if (state.published != null) {
          _answerController.clear();
          context.showSuccess('Réponse publiée.');
          return;
        }
        final error = state.answerError;
        if (error != null) {
          context.showError(error);
          return;
        }
        final actionError =
            state.answerActionError ?? state.questionActionError;
        if (actionError != null) context.showError(actionError);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: SafeArea(
          top: false,
          child: BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
            builder: (context, state) {
              return switch (state) {
                QuestionDetailInitial() || QuestionDetailLoading() =>
                  const Center(child: CircularProgressIndicator()),
                QuestionDetailDeleted() => const SizedBox.shrink(),
                QuestionDetailError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: 'Question indisponible',
                      message: message,
                      action: FilledButton.icon(
                        onPressed: () =>
                            context.read<QuestionDetailCubit>().load(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Réessayer'),
                      ),
                    ),
                  ),
                ),
                QuestionDetailLoaded(
                  :final question,
                  :final answers,
                  :final isSubmitting,
                  :final editingAnswerId,
                ) =>
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _QuestionCard(
                              question: question,
                              isOwn: cubit.isOwnQuestion(question),
                              onEditPressed: () =>
                                  _editQuestion(context, question),
                              onDeletePressed: () =>
                                  _confirmDeleteQuestion(context, cubit),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Réponses (${question.answersCount})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (answers.isEmpty)
                              const EmptyState(
                                icon: Icons.chat_bubble_outline,
                                message:
                                    'Aucune réponse pour le moment. '
                                    'Soyez le premier à répondre.',
                                compact: true,
                              )
                            else
                              for (final answer in answers)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _AnswerCard(
                                    key: ValueKey(answer.id),
                                    answer: answer,
                                    isOwn: cubit.isOwnAnswer(answer),
                                    isEditing: editingAnswerId == answer.id,
                                    onEditPressed: () =>
                                        cubit.startEditing(answer.id),
                                    onCancelEdit: () =>
                                        cubit.startEditing(null),
                                    onSaveEdit: (content) =>
                                        cubit.editAnswer(answer.id, content),
                                    onDeletePressed: () => _confirmDelete(
                                      context,
                                      cubit,
                                      answer.id,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                      _AnswerComposer(
                        controller: _answerController,
                        enabled: !isSubmitting,
                        onSubmitted: () => _submit(cubit),
                      ),
                    ],
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    this.isOwn = false,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final Question question;
  final bool isOwn;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                if (isOwn) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Modifier',
                    onPressed: onEditPressed,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Supprimer',
                    onPressed: onDeletePressed,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${question.type.label} · ${question.createdAt.timeAgo()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AuthorInfo(
              name: question.authorName ?? 'Utilisateur',
              avatarUrl: question.authorPhoto,
              avatarRadius: 11,
            ),
            if (question.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in question.tags) Chip(label: Text(tag)),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.outlineVariant),
            const SizedBox(height: 10),
            AppMarkdown(data: question.content),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({
    super.key,
    required this.answer,
    required this.isOwn,
    required this.isEditing,
    required this.onEditPressed,
    required this.onCancelEdit,
    required this.onSaveEdit,
    required this.onDeletePressed,
  });

  final Answer answer;
  final bool isOwn;
  final bool isEditing;
  final VoidCallback onEditPressed;
  final VoidCallback onCancelEdit;
  final ValueChanged<String> onSaveEdit;
  final VoidCallback onDeletePressed;

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.answer.content);
  }

  @override
  void didUpdateWidget(covariant _AnswerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && !oldWidget.isEditing) {
      _editController.text = widget.answer.content;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AuthorInfo(
                  name: widget.answer.authorName ?? 'Utilisateur',
                  avatarUrl: widget.answer.authorPhoto,
                  avatarRadius: 10,
                ),
                const Spacer(),
                Text(
                  widget.answer.createdAt.timeAgo(),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (widget.isOwn && !widget.isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Modifier',
                    onPressed: widget.onEditPressed,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Supprimer',
                    onPressed: widget.onDeletePressed,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            if (widget.isEditing) ...[
              TextField(
                controller: _editController,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancelEdit,
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () => widget.onSaveEdit(_editController.text),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ] else
              AppMarkdown(data: widget.answer.content),
          ],
        ),
      ),
    );
  }
}

/// Saisie d'une réponse, collée au bas de l'écran.
class _AnswerComposer extends StatelessWidget {
  const _AnswerComposer({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            enabled: enabled,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Écrivez votre réponse…',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: enabled ? onSubmitted : null,
              icon: enabled
                  ? const SizedBox.shrink()
                  : const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
              label: Text(enabled ? 'Répondre' : 'Envoi…'),
            ),
          ),
        ],
      ),
    );
  }
}
