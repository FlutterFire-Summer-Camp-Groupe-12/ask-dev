import 'package:askdev/features/forum/domain/entities/question.dart';
import 'package:equatable/equatable.dart';

/// Contributions d'un utilisateur, affichées sur son profil.
class UserActivity extends Equatable {
  const UserActivity({
    required this.questionsCount,
    required this.answersCount,
    required this.recentQuestions,
  });

  final int questionsCount;
  final int answersCount;

  /// Dernières questions publiées, de la plus récente à la plus ancienne.
  final List<Question> recentQuestions;

  @override
  List<Object?> get props => [questionsCount, answersCount, recentQuestions];
}
