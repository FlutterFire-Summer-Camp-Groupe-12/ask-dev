/// Découpage de texte en mots-clés de recherche.
///
/// Firestore n'a pas de recherche plein texte : chaque question stocke la
/// liste de ses mots-clés (`searchKeywords`) et la recherche interroge ce
/// tableau avec `array-contains`. L'écriture ([buildKeywords]) et la lecture
/// ([SearchQuery]) doivent donc normaliser le texte exactement de la même
/// façon, d'où cette classe unique.
abstract final class SearchText {
  /// Plafond du nombre de mots-clés par question. Large devant les limites
  /// Firestore (1 Mio par document, 40 000 entrées d'index), mais borne le
  /// coût d'écriture d'une très longue description.
  static const int maxKeywords = 300;

  static const int _minTokenLength = 2;

  static final RegExp _separators = RegExp(r'[^a-z0-9+#._-]+');
  static final RegExp _edgePunctuation = RegExp(r'^[._-]+|[._-]+$');
  static final RegExp _innerPunctuation = RegExp(r'[._-]+');

  static const Map<String, String> _accents = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
  };

  /// Mots trop fréquents pour aider à trouver une question, en français et en
  /// anglais (sans accents, après normalisation).
  static const Set<String> stopWords = {
    // Français
    'au', 'aux', 'avec', 'ce', 'ces', 'cet', 'cette', 'dans', 'de', 'des',
    'du', 'elle', 'elles', 'en', 'est', 'et', 'il', 'ils', 'je', 'la', 'le',
    'les', 'leur', 'ma', 'mais', 'me', 'mes', 'mon', 'ne', 'nous', 'on', 'ou',
    'par', 'pas', 'pour', 'qu', 'que', 'qui', 'sa', 'se', 'ses', 'son', 'sont',
    'sur', 'ta', 'te', 'tes', 'ton', 'tu', 'un', 'une', 'vos', 'votre',
    'vous', 'ai', 'as', 'ca', 'comment', 'pourquoi', 'quel', 'quelle',
    // Anglais
    'an', 'and', 'are', 'be', 'but', 'by', 'can', 'do', 'does', 'for', 'from',
    'how', 'if', 'in', 'is', 'it', 'my', 'not', 'of', 'or', 'so',
    'that', 'the', 'this', 'to', 'what', 'when', 'why', 'with',
  };

  /// Minuscules et lettres accentuées ramenées à leur forme simple, pour que
  /// « Réponse » et « reponse » se retrouvent.
  static String normalize(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString();
  }

  /// Mots utiles de [text], dans l'ordre d'apparition et sans doublon.
  ///
  /// Un mot composé (`get_it`, `node.js`, `state-management`) est gardé entier
  /// et aussi découpé, pour être trouvé par chacune de ses parties.
  static List<String> tokenize(String text) {
    final tokens = <String>{};
    for (final raw in normalize(text).split(_separators)) {
      final word = raw.replaceAll(_edgePunctuation, '');
      _addToken(tokens, word);
      if (_innerPunctuation.hasMatch(word)) {
        for (final part in word.split(_innerPunctuation)) {
          _addToken(tokens, part);
        }
      }
    }
    return tokens.toList(growable: false);
  }

  /// Mots-clés stockés sur une question.
  ///
  /// Ordre de priorité face au plafond [maxKeywords] : mots du titre, tags,
  /// débuts des mots du titre (recherche pendant la frappe), puis mots de la
  /// description.
  static List<String> buildKeywords({
    required String title,
    required List<String> tags,
    required String content,
  }) {
    final keywords = <String>{};
    void addAll(Iterable<String> words) {
      for (final word in words) {
        if (keywords.length >= maxKeywords) return;
        keywords.add(word);
      }
    }

    final titleTokens = tokenize(title);
    addAll(titleTokens);
    addAll(tags.expand(tokenize));
    addAll(titleTokens.expand(_prefixes));
    addAll(tokenize(content));
    return keywords.toList(growable: false);
  }

  static Iterable<String> _prefixes(String word) sync* {
    for (var end = _minTokenLength; end < word.length; end++) {
      yield word.substring(0, end);
    }
  }

  static void _addToken(Set<String> tokens, String word) {
    if (word.length < _minTokenLength) return;
    if (stopWords.contains(word)) return;
    tokens.add(word);
  }
}

/// Recherche saisie par l'utilisateur, prête à être envoyée à Firestore.
///
/// Firestore n'accepte qu'un seul `array-contains` par requête : un mot
/// « pivot » ([anchor]) filtre côté serveur, puis [matches] vérifie les
/// autres mots sur les documents reçus.
class SearchQuery {
  const SearchQuery._(this.tokens, this.anchor);

  factory SearchQuery.parse(String input) {
    final tokens = SearchText.tokenize(input);
    if (tokens.isEmpty) return const SearchQuery._([], null);

    // Le dernier mot est peut-être en cours de frappe : il ne sert de pivot
    // que s'il est seul ou déjà suivi d'un espace. Parmi les mots complets,
    // le plus long est en général le plus sélectif.
    final lastIsComplete = input.isNotEmpty && input.trimRight() != input;
    final complete = lastIsComplete || tokens.length == 1
        ? tokens
        : tokens.sublist(0, tokens.length - 1);
    final anchor = complete.reduce((a, b) => b.length > a.length ? b : a);
    return SearchQuery._(tokens, anchor);
  }

  final List<String> tokens;

  /// Mot envoyé à Firestore, `null` quand la recherche est vide.
  final String? anchor;

  bool get isEmpty => anchor == null;

  /// Vrai si chaque mot de la recherche est un mot-clé de la question ou le
  /// début de l'un d'eux.
  bool matches(List<String> keywords) {
    return tokens.every(
      (token) => keywords.any((keyword) => keyword.startsWith(token)),
    );
  }
}
