import 'package:askdev/features/forum/domain/entities/answer_with_question.dart';
import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyContributionsState extends Equatable {
  const MyContributionsState({
    this.isLoading = false,
    this.questions = const [],
    this.answers = const [],
    this.error,
  });

  final bool isLoading;
  final List<Question> questions;
  final List<AnswerWithQuestion> answers;
  final String? error;

  @override
  List<Object?> get props => [isLoading, questions, answers, error];
}

/// Les questions et réponses de l'utilisateur courant, pour l'écran
/// « Mes contributions ». Les deux listes partent ensemble ; à l'échec d'une
/// des deux, la liste déjà chargée reste affichée.
class MyContributionsCubit extends Cubit<MyContributionsState> {
  MyContributionsCubit(this._repository) : super(const MyContributionsState());

  final QuestionRepository _repository;

  Future<void> load(String userId) async {
    if (userId.isEmpty) return;
    emit(
      MyContributionsState(
        isLoading: true,
        questions: state.questions,
        answers: state.answers,
      ),
    );
    final results = await (
      _repository.getQuestionsByAuthor(userId),
      _repository.getAnswersByAuthor(userId),
    ).wait;
    if (isClosed) return;

    final questions =
        results.$1.getOrElse(
          (_) => state.questions,
        );
    final answers = results.$2.getOrElse((_) => state.answers);
    final error = switch ((results.$1.isLeft(), results.$2.isLeft())) {
      (true, true) => results.$1.getLeft().toNullable()?.message,
      (true, false) => results.$1.getLeft().toNullable()?.message,
      (false, true) => results.$2.getLeft().toNullable()?.message,
      (false, false) => null,
    };
    emit(MyContributionsState(questions: questions, answers: answers, error: error));
  }
}