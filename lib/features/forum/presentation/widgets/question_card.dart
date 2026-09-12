import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, required this.onTap});

  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(question.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(question.content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${question.answersCount}'),
            const Text('réponses', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}