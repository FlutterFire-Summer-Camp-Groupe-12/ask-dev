import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/question_slice.dart';
import '../repositories/question_repository.dart';
import '../search/search_text.dart';

class SearchQuestions {
  const SearchQuestions(this.repository);

  final QuestionRepository repository;

  Future<Either<Failure, QuestionSlice>> call(
    SearchQuery query, {
    String? startAfter,
  }) {
    return repository.searchQuestions(query, startAfter: startAfter);
  }
}
