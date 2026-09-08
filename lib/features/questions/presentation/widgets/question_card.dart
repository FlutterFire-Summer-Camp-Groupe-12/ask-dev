import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback onTap;

  const QuestionCard({super.key, required this.question, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(question.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(question.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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