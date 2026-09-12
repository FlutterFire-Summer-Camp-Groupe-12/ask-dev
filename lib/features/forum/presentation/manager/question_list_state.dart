import 'package:equatable/equatable.dart';

import '../../domain/entities/question.dart';

sealed class QuestionListState extends Equatable {
  const QuestionListState();
  @override
  List<Object?> get props => [];
}

class QuestionListInitial extends QuestionListState {
  const QuestionListInitial();
}

class QuestionListLoading extends QuestionListState {
  const QuestionListLoading();
}

class QuestionListLoaded extends QuestionListState {
  const QuestionListLoaded(this.questions);
  final List<Question> questions;
  @override
  List<Object?> get props => [questions];
}

class QuestionListError extends QuestionListState {
  const QuestionListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}