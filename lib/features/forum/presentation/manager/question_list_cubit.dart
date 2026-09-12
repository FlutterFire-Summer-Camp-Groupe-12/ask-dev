import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_recent_questions.dart';
import 'question_list_state.dart';

class QuestionListCubit extends Cubit<QuestionListState> {
  QuestionListCubit(this.getRecentQuestions) : super(const QuestionListInitial());

  final GetRecentQuestions getRecentQuestions;

  Future<void> load() async {
    emit(const QuestionListLoading());
    final result = await getRecentQuestions();
    result.match(
      (failure) => emit(QuestionListError(failure.message)),
      (questions) => emit(QuestionListLoaded(questions)),
    );
  }
}