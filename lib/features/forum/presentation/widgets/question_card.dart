import 'package:askdev/core/utils/markdown.dart';
import 'package:askdev/core/utils/type_extensions.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';

/// Carte d'aperçu d'une question : titre (16–17sp semi-bold), extrait du
/// contenu avec la syntaxe Markdown retirée (le rendu appartient au détail),
/// et métadonnées (nombre de réponses, âge).
class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, required this.onTap});

  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final replies = question.answersCount == 1
        ? '1 réponse'
        : '${question.answersCount} réponses';
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                stripMarkdown(question.content),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$replies · ${question.createdAt.timeAgo()}',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}