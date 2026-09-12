import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_injection/injection.dart';
import '../manager/question_list_cubit.dart';
import '../manager/question_list_state.dart';
import '../widgets/question_card.dart';

@RoutePage()
class QuestionsHomePage extends StatelessWidget {
  const QuestionsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuestionListCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('AskDev — Questions récentes')),
        body: BlocBuilder<QuestionListCubit, QuestionListState>(
          builder: (context, state) {
            return switch (state) {
              QuestionListInitial() ||
              QuestionListLoading() =>
                const Center(child: CircularProgressIndicator()),
              QuestionListError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        Text(message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<QuestionListCubit>().load(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              QuestionListLoaded(:final questions) => questions.isEmpty
                  ? const Center(child: Text('Aucune question pour le moment.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: QuestionCard(
                            question: question,
                            onTap: () {
                              // TODO: navigation vers le détail, une fois la route créée
                            },
                          ),
                        );
                      },
                    ),
            };
          },
        ),
      ),
    );
  }
}