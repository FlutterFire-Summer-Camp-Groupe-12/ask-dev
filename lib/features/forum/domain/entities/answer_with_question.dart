import 'package:askdev/features/forum/domain/entities/answer.dart';
import 'package:equatable/equatable.dart';

/// Une réponse enrichie du titre et de l'identifiant de la question parente,
/// pour afficher les réponses d'un utilisateur sans perdre le contexte.
class AnswerWithQuestion extends Equatable {
  const AnswerWithQuestion({
    required this.answer,
    required this.questionId,
    required this.questionTitle,
  });

  final Answer answer;
  final String questionId;
  final String questionTitle;

  @override
  List<Object?> get props => [answer, questionId, questionTitle];
}
