import 'package:askdev/features/forum/domain/search/search_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchText.tokenize', () {
    test('folds accents and case', () {
      expect(SearchText.tokenize('Réponse ÉLÈVE'), ['reponse', 'eleve']);
    });

    test('drops stop words and single characters', () {
      expect(SearchText.tokenize('Comment utiliser le cubit ? a'), [
        'utiliser',
        'cubit',
      ]);
    });

    test('keeps compound words and their parts', () {
      expect(SearchText.tokenize('node.js get_it'), [
        'node.js',
        'node',
        'js',
        'get_it',
        'get',
      ]);
    });

    test('strips sentence punctuation around words', () {
      expect(SearchText.tokenize('Ça plante... encore.'), ['plante', 'encore']);
    });
  });

  group('SearchText.buildKeywords', () {
    test('adds title prefixes and content words', () {
      final keywords = SearchText.buildKeywords(
        title: 'Flutter',
        tags: const ['dart'],
        content: 'Erreur avec Firestore',
      );

      expect(keywords, containsAll(['flutter', 'dart', 'fl', 'flutte']));
      expect(keywords, containsAll(['erreur', 'firestore']));
      // Pas de préfixes pour la description : elle se cherche par mots entiers.
      expect(keywords, isNot(contains('fire')));
    });

    test('is capped', () {
      final content = List.generate(1000, (i) => 'mot$i').join(' ');
      final keywords = SearchText.buildKeywords(
        title: 'Titre',
        tags: const [],
        content: content,
      );

      expect(keywords, hasLength(SearchText.maxKeywords));
      expect(keywords.first, 'titre');
    });
  });

  group('SearchQuery', () {
    test('is empty without useful words', () {
      expect(SearchQuery.parse('  le la ').isEmpty, isTrue);
    });

    test('does not anchor on the word being typed', () {
      final query = SearchQuery.parse('firestore pagin');
      expect(query.anchor, 'firestore');
    });

    test('anchors on the longest word once typing is finished', () {
      final query = SearchQuery.parse('bloc pagination ');
      expect(query.anchor, 'pagination');
    });

    test('matches every word, the others by prefix', () {
      final keywords = SearchText.buildKeywords(
        title: 'Pagination Firestore',
        tags: const [],
        content: 'startAfterDocument ne marche pas',
      );

      expect(
        SearchQuery.parse('firestore startafter').matches(keywords),
        isTrue,
      );
      expect(
        SearchQuery.parse('firestore riverpod').matches(keywords),
        isFalse,
      );
    });
  });
}
