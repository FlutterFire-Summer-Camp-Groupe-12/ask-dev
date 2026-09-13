import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../dependency_injection/injection.dart';
import '../manager/question_list_cubit.dart';
import '../manager/question_list_state.dart';
import '../widgets/question_card.dart';

@RoutePage()
class QuestionsHomePage extends StatefulWidget {
  const QuestionsHomePage({super.key});

  @override
  State<QuestionsHomePage> createState() => _QuestionsHomePageState();
}

class _QuestionsHomePageState extends State<QuestionsHomePage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<QuestionListCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Accueil')),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une question…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Effacer',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<QuestionListCubit, QuestionListState>(
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
                                  onPressed: () =>
                                      context.read<QuestionListCubit>().load(),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      QuestionListLoaded(:final questions) =>
                        _buildList(questions),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Question> questions) {
    if (questions.isEmpty) {
      return const Center(child: Text('Aucune question pour le moment.'));
    }
    final q = _query.trim().toLowerCase();
    // ponytail: recherche côté client sur les questions déjà chargées
    final filtered = q.isEmpty
        ? questions
        : questions
            .where((question) =>
                question.searchKeywords.any((keyword) => keyword.contains(q)))
            .toList();
    if (filtered.isEmpty) {
      return Center(child: Text('Aucun résultat pour « $q ».'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final question = filtered[index];
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
    );
  }
}