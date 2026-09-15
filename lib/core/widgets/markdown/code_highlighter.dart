import 'package:flutter/painting.dart';
import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/bash.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/gradle.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/typescript.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/yaml.dart';

/// Colore un extrait de code en [TextSpan], à partir d'un thème highlight.js
/// (`Map<classe CSS, TextStyle>`).
///
/// Seuls les langages courants d'un forum mobile sont enregistrés : la
/// détection automatique teste chaque langage connu, la liste courte la garde
/// rapide. Un langage inconnu ou une erreur d'analyse donne du texte brut.
class CodeHighlighter {
  CodeHighlighter._();

  static final CodeHighlighter instance = CodeHighlighter._();

  static const int _cacheSize = 64;

  static final Map<String, Mode> _languages = {
    'dart': dart,
    'kotlin': kotlin,
    'swift': swift,
    'java': java,
    'javascript': javascript,
    'typescript': typescript,
    'json': json,
    'yaml': yaml,
    'xml': xml,
    'bash': bash,
    'python': python,
    'sql': sql,
    'css': css,
    'gradle': gradle,
    'cpp': cpp,
    'go': go,
    'php': php,
  };

  final Highlight _highlight = Highlight()..registerLanguages(_languages);

  /// Noms et alias acceptés après les triples backticks (js, yml, sh...).
  final Set<String> _knownNames = {
    for (final entry in _languages.entries) ...[
      entry.key,
      ...?entry.value.aliases?.map((alias) => alias.toLowerCase()),
    ],
  };

  // Le détail d'une question se reconstruit souvent (saisie d'une réponse) :
  // on garde les derniers résultats d'analyse, clé = langage + source.
  final Map<String, Result?> _cache = {};

  /// Langage retenu pour [source] : celui annoncé s'il est connu, sinon le
  /// plus probable par détection automatique, ou `null` pour du texte brut.
  String? resolveLanguage(String source, {String? language}) {
    return _parse(source, language)?.language;
  }

  TextSpan format(
    String source, {
    required Map<String, TextStyle> theme,
    String? language,
  }) {
    final nodes = _parse(source, language)?.nodes;
    if (nodes == null) return TextSpan(text: source);
    return TextSpan(children: _toSpans(nodes, theme));
  }

  Result? _parse(String source, String? language) {
    final key = '${language ?? ''}\u0000$source';
    if (_cache.containsKey(key)) return _cache[key];

    Result? result;
    try {
      final known =
          language != null && _knownNames.contains(language.toLowerCase());
      result = known
          ? _highlight.parse(source, language: language)
          : _highlight.parse(source, autoDetection: true);
      if (!known && (result.language == null || (result.relevance ?? 0) < 2)) {
        // Détection trop hésitante : mieux vaut du texte neutre qu'une
        // coloration fausse.
        result = null;
      }
    } catch (_) {
      result = null;
    }

    if (_cache.length >= _cacheSize) _cache.remove(_cache.keys.first);
    _cache[key] = result;
    return result;
  }

  List<TextSpan> _toSpans(List<Node> nodes, Map<String, TextStyle> theme) {
    return [
      for (final node in nodes)
        if (node.value != null)
          TextSpan(text: node.value, style: theme[node.className])
        else if (node.children != null)
          TextSpan(
            style: theme[node.className],
            children: _toSpans(node.children!, theme),
          ),
    ];
  }
}
