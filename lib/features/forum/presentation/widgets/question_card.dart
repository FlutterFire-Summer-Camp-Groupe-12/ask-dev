import 'package:askdev/core/themes/app_palette.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/markdown.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:askdev/core/widgets/author_info.dart';
import 'package:askdev/core/widgets/skeleton.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';

/// Aperçu d'une question dans une liste : type et âge, titre sur deux
/// lignes, extrait sans Markdown, tags, auteur et nombre de réponses.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.onTap,
    this.showAuthor = true,
  });

  final Question question;
  final VoidCallback onTap;

  /// Masqué sur le profil, où l'auteur est toujours le même.
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final excerpt = stripMarkdown(question.content);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${question.type.label} · ${question.createdAt.timeAgo()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelSmall,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                question.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.titleMedium,
              ),
              if (excerpt.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall,
                ),
              ],
              if (question.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                TagWrap(tags: question.tags, maxVisible: 3),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: showAuthor
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: AuthorInfo(
                              name: question.authorName ?? 'Utilisateur',
                              avatarUrl: question.authorPhoto,
                              avatarSize: 22,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AnswerCountBadge(count: question.answersCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nombre de réponses, mis en valeur en vert dès la première réponse.
class AnswerCountBadge extends StatelessWidget {
  const AnswerCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = context.palette;
    final answered = count > 0;
    final foreground = answered
        ? palette.onSuccessContainer
        : colors.onSurfaceVariant;
    final label = switch (count) {
      0 => 'Sans réponse',
      1 => '1 réponse',
      _ => '$count réponses',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: answered ? palette.successContainer : Colors.transparent,
        borderRadius: AppRadius.smAll,
        border: answered ? null : Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            answered
                ? Icons.check_circle_rounded
                : Icons.chat_bubble_outline_rounded,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Réserve la place d'une [QuestionCard] pendant le chargement.
class QuestionCardSkeleton extends StatelessWidget {
  const QuestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 10),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 16),
            SizedBox(height: AppSpacing.xs + 2),
            SkeletonBox(width: 220, height: 16),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 10),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SkeletonBox(height: 22, circle: true),
                SizedBox(width: AppSpacing.sm),
                SkeletonBox(width: 80, height: 10),
                Spacer(),
                SkeletonBox(width: 72, height: 22, radius: AppRadius.sm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Liste de [QuestionCardSkeleton] animée d'un seul battement.
class QuestionListSkeleton extends StatelessWidget {
  const QuestionListSkeleton({super.key, this.count = 4, this.padding});

  final int count;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? AppLayout.listPadding(context),
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, _) => const QuestionCardSkeleton(),
      ),
    );
  }
}
