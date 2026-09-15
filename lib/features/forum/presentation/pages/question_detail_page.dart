import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/author_info.dart';
import 'package:askdev/core/widgets/confirm_dialog.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/core/widgets/markdown/app_markdown.dart';
import 'package:askdev/core/widgets/skeleton.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
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
import 'package:askdev/features/forum/presentation/widgets/markdown_toolbar.dart';
import 'package:askdev/features/forum/presentation/widgets/question_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _submit(QuestionDetailCubit cubit) {
    if (_answerController.text.trim().isEmpty) return;
    cubit.submitAnswer(_answerController.text);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteAnswer(
    BuildContext context,
    QuestionDetailCubit cubit,
    String answerId,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: 'Supprimer cette réponse ?',
      message: 'Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (confirmed) cubit.removeAnswer(answerId);
  }

  Future<void> _confirmDeleteQuestion(
    BuildContext context,
    QuestionDetailCubit cubit,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: 'Supprimer cette question ?',
      message:
          'La question et toutes ses réponses seront supprimées. '
          'Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (confirmed) cubit.deleteQuestion();
  }

  Future<void> _editQuestion(BuildContext context, Question question) async {
    final cubit = context.read<QuestionDetailCubit>();
    final updated = await context.router.push<Question>(
      EditQuestionRoute(question: question),
    );
    // Recharge la question modifiée (contenu, tags, type) depuis Firestore.
    if (updated != null) cubit.load();
  }

  @override
  Widget build(BuildContext context) {
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
          FocusScope.of(context).unfocus();
          HapticFeedback.mediumImpact();
          context.showSuccess('Réponse publiée.');
          return;
        }
        final error =
            state.answerError ??
            state.answerActionError ??
            state.questionActionError;
        if (error != null) context.showError(error);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Question'),
          actions: [
            BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
              builder: (context, state) {
                if (state is! QuestionDetailLoaded ||
                    !cubit.isOwnQuestion(state.question)) {
                  return const SizedBox.shrink();
                }
                return _OwnerMenu(
                  onEdit: () => _editQuestion(context, state.question),
                  onDelete: () => _confirmDeleteQuestion(context, cubit),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<QuestionDetailCubit, QuestionDetailState>(
          builder: (context, state) {
            return switch (state) {
              QuestionDetailInitial() ||
              QuestionDetailLoading() => const _DetailSkeleton(),
              QuestionDetailDeleted() => const SizedBox.shrink(),
              QuestionDetailError(:final message) => Center(
                child: SingleChildScrollView(
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Question indisponible',
                    message: message,
                    action: FilledButton.icon(
                      onPressed: cubit.load,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
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
                        padding: AppLayout.listPadding(context, bottom: 0),
                        children: [
                          _QuestionHeader(question: question),
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              Text(
                                answers.length == 1
                                    ? '1 réponse'
                                    : '${answers.length} réponses',
                                style: context.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (answers.isEmpty)
                            const EmptyState(
                              icon: Icons.chat_bubble_outline_rounded,
                              message:
                                  'Aucune réponse pour le moment. '
                                  'Soyez le premier à répondre.',
                              compact: true,
                            )
                          else
                            for (final answer in answers)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: _AnswerCard(
                                  key: ValueKey(answer.id),
                                  answer: answer,
                                  isOwn: cubit.isOwnAnswer(answer),
                                  isEditing: editingAnswerId == answer.id,
                                  onEditPressed: () =>
                                      cubit.startEditing(answer.id),
                                  onCancelEdit: () => cubit.startEditing(null),
                                  onSaveEdit: (content) =>
                                      cubit.editAnswer(answer.id, content),
                                  onDeletePressed: () => _confirmDeleteAnswer(
                                    context,
                                    cubit,
                                    answer.id,
                                  ),
                                ),
                              ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                    _AnswerComposer(
                      controller: _answerController,
                      isSubmitting: isSubmitting,
                      onSubmitted: () => _submit(cubit),
                    ),
                  ],
                ),
            };
          },
        ),
      ),
    );
  }
}

/// Menu « Modifier / Supprimer » de l'auteur.
class _OwnerMenu extends StatelessWidget {
  const _OwnerMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Actions',
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: onEdit,
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Modifier'),
          ),
        ),
        PopupMenuItem(
          value: onDelete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            iconColor: colors.error,
            textColor: colors.error,
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('Supprimer'),
          ),
        ),
      ],
    );
  }
}

/// En-tête de la question : type, titre, auteur, tags et contenu.
class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TagChip(question.type.label),
            const Spacer(),
            AnswerCountBadge(count: question.answersCount),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SelectableText(question.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        AuthorInfo(
          name: question.authorName ?? 'Utilisateur',
          subtitle: 'a demandé ${question.createdAt.timeAgo()}',
          avatarUrl: question.authorPhoto,
          avatarSize: 34,
        ),
        if (question.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          TagWrap(tags: question.tags),
        ],
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),
        AppMarkdown(data: question.content),
      ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AuthorInfo(
                      name: widget.answer.authorName ?? 'Utilisateur',
                      subtitle:
                          'a répondu ${widget.answer.createdAt.timeAgo()}',
                      avatarUrl: widget.answer.authorPhoto,
                      avatarSize: 28,
                    ),
                  ),
                ),
                if (widget.isOwn && !widget.isEditing)
                  _OwnerMenu(
                    onEdit: widget.onEditPressed,
                    onDelete: widget.onDeletePressed,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (widget.isEditing) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    MarkdownToolbar(controller: _editController),
                    TextField(
                      controller: _editController,
                      minLines: 3,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancelEdit,
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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

/// Saisie d'une réponse, collée au bas de l'écran. La barre Markdown
/// apparaît quand le champ prend le focus.
class _AnswerComposer extends StatefulWidget {
  const _AnswerComposer({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmitted;

  @override
  State<_AnswerComposer> createState() => _AnswerComposerState();
}

class _AnswerComposerState extends State<_AnswerComposer> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_focusNode.hasFocus)
                MarkdownToolbar(
                  controller: widget.controller,
                  enabled: !widget.isSubmitting,
                  borderRadius: AppRadius.mdAll,
                ),
              if (_focusNode.hasFocus) const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      enabled: !widget.isSubmitting,
                      minLines: 1,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'Écrire une réponse…',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller,
                    builder: (context, value, _) {
                      final canSend =
                          value.text.trim().isNotEmpty && !widget.isSubmitting;
                      return IconButton.filled(
                        onPressed: canSend ? widget.onSubmitted : null,
                        tooltip: 'Répondre',
                        iconSize: 20,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        icon: widget.isSubmitting
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Silhouette de la question pendant le chargement.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
        padding: AppLayout.listPadding(context),
        children: const [
          SkeletonBox(width: 120, height: 22, radius: AppRadius.sm),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(height: 20),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 240, height: 20),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              SkeletonBox(height: 34, circle: true),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(width: 120, height: 12),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          SkeletonBox(height: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(height: 12),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 200, height: 12),
          SizedBox(height: AppSpacing.xl),
          QuestionCardSkeleton(),
        ],
      ),
    );
  }
}
