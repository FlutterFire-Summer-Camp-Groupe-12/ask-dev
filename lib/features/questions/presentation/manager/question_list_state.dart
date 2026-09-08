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
  final List<Question> questions;
  const QuestionListLoaded(this.questions);
  @override
  List<Object?> get props => [questions];
}

class QuestionListError extends QuestionListState {
  final String message;
  const QuestionListError(this.message);
  @override
  List<Object?> get props => [message];
}