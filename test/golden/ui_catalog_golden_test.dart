@Tags(['golden'])
library;

import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/app_avatar.dart';
import 'package:askdev/core/widgets/confirm_dialog.dart';
import 'package:askdev/core/widgets/empty_state.dart';
import 'package:askdev/core/widgets/markdown/app_markdown.dart';
import 'package:askdev/core/widgets/section_header.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/presentation/widgets/question_card.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'golden_helpers.dart';

Question _question({
  String id = 'q1',
  String title = 'Comment injecter un cubit avec get_it dans un widget ?',
  int answersCount = 3,
  List<String> tags = const ['flutter', 'bloc', 'get-it'],
}) {
  return Question(
    id: id,
    title: title,
    content:
        'Mon **BlocProvider** ne trouve pas le cubit quand je pousse la page '
        'depuis le shell. Voici le code : `sl<AskQuestionCubit>()`.',
    authorId: 'u1',
    authorName: 'Peng Cheng',
    createdAt: DateTime(2026, 9, 14, 10),
    updatedAt: DateTime(2026, 9, 14, 10),
    answersCount: answersCount,
    searchKeywords: const [],
    type: QuestionType.howTo,
    tags: tags,
  );
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('cartes de question', (tester) async {
    await expectGoldenPair(
      tester,
      'question_cards',
      Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Accueil')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Poser une question'),
          ),
          body: ListView(
            padding: AppLayout.listPadding(context),
            children: [
              QuestionCard(question: _question(), onTap: () {}),
              const SizedBox(height: AppSpacing.md),
              QuestionCard(
                question: _question(
                  id: 'q2',
                  title: 'Firestore renvoie une erreur d\'index manquant',
                  answersCount: 0,
                  tags: const ['firestore', 'index'],
                ),
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              const QuestionCardSkeleton(),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('composants partagés', (tester) async {
    await expectGoldenPair(
      tester,
      'components',
      Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Composants')),
          body: ListView(
            padding: AppLayout.listPadding(context),
            children: [
              Row(
                children: [
                  const AppAvatar(name: 'Peng Cheng', size: 48),
                  const SizedBox(width: AppSpacing.md),
                  const AppAvatar(name: 'Ada', size: 40),
                  const SizedBox(width: AppSpacing.md),
                  const AnswerCountBadge(count: 4),
                  const SizedBox(width: AppSpacing.sm),
                  const AnswerCountBadge(count: 0),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const TagWrap(
                tags: ['flutter', 'dart', 'firebase', 'bloc'],
                maxVisible: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  FilledButton(onPressed: () {}, child: const Text('Publier')),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Annuler'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Votre question en une phrase',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionCard(
                title: 'À propos',
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    'Développeur Flutter, curieux de tout ce qui touche au '
                    'mobile et au temps réel.',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Aucun résultat',
                message: 'Essayez un autre mot, ou posez la question.',
              ),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('rendu Markdown et code', (tester) async {
    await expectGoldenPair(
      tester,
      'markdown',
      Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Question')),
          body: ListView(
            padding: AppLayout.listPadding(context),
            children: const [
              AppMarkdown(
                data: '''
## Le problème

Mon `BlocProvider` ne trouve pas le cubit. Voici le code :

```dart
final cubit = context.read<AskQuestionCubit>();
void main() => runApp(const MyApp());
```

> J'ai déjà essayé de le fournir plus haut dans l'arbre.

- Flutter 3.35
- get_it 9.2
''',
              ),
            ],
          ),
        ),
      ),
    );
  });

  testWidgets('formulaire de question', (tester) async {
    final title = TextEditingController(
      text: 'Comment paginer une liste Firestore ?',
    );
    final content = TextEditingController(
      text: 'Je charge 20 questions et je veux la suite au défilement.',
    );
    addTearDown(title.dispose);
    addTearDown(content.dispose);

    await expectGoldenPair(
      tester,
      'question_form',
      Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: const Icon(Icons.close_rounded),
            title: const Text('Poser une question'),
          ),
          bottomNavigationBar: FormActionBar(
            label: 'Publier la question',
            onPressed: () {},
          ),
          body: ListView(
            padding: AppLayout.listPadding(context),
            children: [
              const QuestionWritingTips(),
              const SizedBox(height: AppSpacing.xl),
              QuestionFormFields(
                type: QuestionType.howTo,
                onTypeChanged: (_) {},
                titleController: title,
                contentController: content,
                tags: const ['firestore', 'pagination'],
                onTagAdded: (_) {},
                onTagRemoved: (_) {},
                contentError: '220 caractères minimum',
                onRequestImage: () async => null,
              ),
            ],
          ),
        ),
      ),
      size: const Size(400, 1100),
    );
  });

  testWidgets('dialogue de confirmation', (tester) async {
    await expectGoldenPair(
      tester,
      'confirm_dialog',
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => showConfirmDialog(
                context,
                icon: Icons.delete_outline_rounded,
                title: 'Supprimer cette question ?',
                message:
                    'La question et toutes ses réponses seront supprimées. '
                    'Cette action est irréversible.',
                confirmLabel: 'Supprimer',
                destructive: true,
              ),
              child: const Text('Supprimer'),
            ),
          ),
        ),
      ),
      size: const Size(400, 400),
    );
  });
}
