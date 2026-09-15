import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/features/forum/domain/entities/question_draft.dart';
import 'package:askdev/features/forum/domain/entities/question_status.dart';
import 'package:askdev/features/forum/domain/entities/question_type.dart';
import 'package:askdev/features/forum/domain/usecases/create_question.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AskQuestionCubit extends Cubit<AskQuestionState> {
  AskQuestionCubit({
    required CreateQuestion createQuestion,
    required AuthGateway authGateway,
  }) : _createQuestion = createQuestion,
       _authGateway = authGateway,
       super(const AskQuestionState());

  final CreateQuestion _createQuestion;
  final AuthGateway _authGateway;

  void typeChanged(QuestionType type) => emit(state.copyWith(type: type));

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void contentChanged(String content) => emit(state.copyWith(content: content));

  /// Ajoute un tag normalisé (minuscules, espaces remplacés par des tirets).
  ///
  /// Les doublons, les entrées vides et tout ajout au-delà de
  /// [AskQuestionState.maxTags] sont ignorés.
  void tagAdded(String value) {
    final tag = _normalizeTag(value);
    if (tag.isEmpty || !state.canAddTag || state.tags.contains(tag)) return;
    emit(state.copyWith(tags: [...state.tags, tag]));
  }

  void tagRemoved(String tag) {
    if (!state.tags.contains(tag)) return;
    emit(state.copyWith(tags: state.tags.where((t) => t != tag).toList()));
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true, error: null));
      return;
    }

    final authorId = _authGateway.currentUserId;
    if (authorId == null) {
      emit(state.copyWith(error: 'Connectez-vous pour publier une question.'));
      return;
    }
    final author = _authGateway.currentUser;

    emit(state.copyWith(isSubmitting: true, error: null, published: null));
    final result = await _createQuestion(
      QuestionDraft(
        authorId: authorId,
        // ponytail: identité dénormalisée pour l'affichage sans relecture ;
        // ré-écrite à la prochaine modification de la question.
        authorName: author?.displayName ?? author?.email,
        authorPhoto: author?.photoUrl,
        title: state.title.trim(),
        content: state.content.trim(),
        type: state.type,
        // ponytail: on ne choisit plus la destination : publication directe.
        status: QuestionStatus.published,
        tags: state.tags,
      ),
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isSubmitting: false, error: failure.message)),
      (question) =>
          emit(const AskQuestionState().copyWith(published: question)),
    );
  }

  String _normalizeTag(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9+#.\-]'), '');
  }
}
