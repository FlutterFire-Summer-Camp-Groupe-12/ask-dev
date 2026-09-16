import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:equatable/equatable.dart';

/// Une page de questions et de quoi demander la suivante.
class QuestionSlice extends Equatable {
  const QuestionSlice({required this.questions, this.nextCursor});

  static const QuestionSlice empty = QuestionSlice(questions: []);

  final List<Question> questions;

  /// Identifiant de la dernière question parcourue, à renvoyer pour obtenir
  /// la page suivante. `null` quand il n'y a plus rien à charger.
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [questions, nextCursor];
}
