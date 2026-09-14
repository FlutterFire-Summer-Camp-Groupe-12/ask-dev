import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/get_answers.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
        getAnswers: sl<GetAnswers>(),
        createAnswer: sl<CreateAnswer>(),
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<QuestionDetailCubit>();
    return BlocListener<QuestionDetailCubit, QuestionDetailState>(
      listenWhen: (previous, current) {
        if (previous is! QuestionDetailLoaded ||
            current is! QuestionDetailLoaded) {
          return false;
        }
        return previous.published != current.published ||
            (current.answerError != null &&
                previous.answerError != current.answerError);
      },
      listener: (context, state) {
        if (state is! QuestionDetailLoaded) return;
        if (state.published != null) {
          _answerController.clear();
          context.showSuccess('Réponse publiée.');
          return;
        }
        final error = state.answerError;
        if (error != null) context.showError(error);
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
                QuestionDetailError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.error_outline,
                        title: 'Question indisponible',
                        message: message,
                        action: FilledButton.icon(
                          onPressed: () => context
                              .read<QuestionDetailCubit>()
                              .load(),
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
                ) =>
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _QuestionCard(question: question),
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
                                  child: _AnswerCard(answer: answer),
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
  const _QuestionCard({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
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
            MarkdownBody(
              data: question.content,
              selectable: true,
              styleSheet: _markdownStyle(theme),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.answer});

  final Answer answer;

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
            Text(
              answer.createdAt.timeAgo(),
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            MarkdownBody(
              data: answer.content,
              selectable: true,
              styleSheet: _markdownStyle(theme),
            ),
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

/// Apparence du markdown alignée sur le thème de l'app (corps 14, hauteur
/// confortable, palette issue du ColorScheme).
MarkdownStyleSheet _markdownStyle(ThemeData theme) {
  final colors = theme.colorScheme;
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: TextStyle(fontSize: 14, height: 1.5, color: colors.onSurface),
    blockquote: TextStyle(
      fontSize: 14,
      height: 1.5,
      color: colors.onSurfaceVariant,
      fontStyle: FontStyle.italic,
    ),
    code: TextStyle(
      fontSize: 13,
      backgroundColor: colors.surfaceContainerHighest,
      color: colors.onSurface,
    ),
    codeblockDecoration: BoxDecoration(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}