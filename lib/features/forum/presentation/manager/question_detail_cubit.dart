import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/answer_draft.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/get_answers.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/presentation/manager/question_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState> {
  QuestionDetailCubit({
    required String questionId,
    required GetQuestionById getQuestionById,
    required GetAnswers getAnswers,
    required CreateAnswer createAnswer,
    required AuthGateway authGateway,
  })  : _questionId = questionId,
        _getQuestionById = getQuestionById,
        _getAnswers = getAnswers,
        _createAnswer = createAnswer,
        _authGateway = authGateway,
        super(const QuestionDetailInitial());

  final String _questionId;
  final GetQuestionById _getQuestionById;
  final GetAnswers _getAnswers;
  final CreateAnswer _createAnswer;
  final AuthGateway _authGateway;

  Future<void> load() async {
    emit(const QuestionDetailLoading());
    final questionResult = await _getQuestionById(_questionId);
    final question = questionResult.fold(
      (failure) {
        emit(QuestionDetailError(failure.message));
        return null;
      },
      (loaded) => loaded,
    );
    if (question == null || state is QuestionDetailError) return;

    final answersResult = await _getAnswers(_questionId);
    answersResult.fold(
      (failure) => emit(QuestionDetailError(failure.message)),
      (answers) => emit(
        QuestionDetailLoaded(question: question, answers: answers),
      ),
    );
  }

  Future<void> submitAnswer(String content) async {
    final current = state;
    if (current is! QuestionDetailLoaded || current.isSubmitting) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      emit(current.copyWith(answerError: 'Rédigez une réponse avant d’envoyer.'));
      return;
    }

    final authorId = _authGateway.currentUserId;
    if (authorId == null) {
      emit(current.copyWith(answerError: 'Connectez-vous pour répondre.'));
      return;
    }

    emit(current.copyWith(isSubmitting: true, answerError: null, published: null));
    final result = await _createAnswer(
      _questionId,
      AnswerDraft(content: trimmed, authorId: authorId),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, answerError: failure.message),
      ),
      (answer) => emit(
        QuestionDetailLoaded(
          question: current.question.copyWith(
            answersCount: current.question.answersCount + 1,
          ),
          answers: [...current.answers, answer],
          published: answer,
        ),
      ),
    );
  }
}