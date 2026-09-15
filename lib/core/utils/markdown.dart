/// Nettoyage de texte brut pour les aperçus (ex. extrait d'une question en
/// liste). Ne rend PAS le markdown : il retire la syntaxe pour afficher le
/// texte restant proprement. Le vrai rendu appartient à l'écran de détail.
library;

final RegExp _imageRegExp = RegExp(r'!\[[^\]]*\]\([^)]*\)');
final RegExp _linkRegExp = RegExp(r'\[([^\]]+)\]\([^)]*\)');
final RegExp _inlineCodeRegExp = RegExp(r'`([^`]*)`');
final RegExp _fenceRegExp = RegExp(r'```[\s\S]*?```');
final RegExp _headingRegExp = RegExp(r'^#{1,6}\s*', multiLine: true);
final RegExp _boldRegExp = RegExp(r'\*\*([^*]+)\*\*');
final RegExp _boldUnderRegExp = RegExp(r'__([^_]+)__');
final RegExp _italicRegExp = RegExp(r'\*([^*]+)\*');
final RegExp _italicUnderRegExp = RegExp(r'([\s(])_([^_]+)_([\s).,!?;:])');
final RegExp _strikeRegExp = RegExp(r'~~([^~]+)~~');
final RegExp _blockquoteRegExp = RegExp(r'^\s*>\s?', multiLine: true);
final RegExp _bulletRegExp = RegExp(r'^\s*[-*+]\s+', multiLine: true);
final RegExp _listRegExp = RegExp(r'^\s*\d+\.\s+', multiLine: true);
final RegExp _ruleRegExp = RegExp(
  r'^\s*([-*_])\s*(\1\s*){2,}\s*$',
  multiLine: true,
);
final RegExp _htmlRegExp = RegExp(r'<[^>]+>');
final RegExp _blankRegExp = RegExp(r'[ \t]+$', multiLine: true);
final RegExp _newlinesRegExp = RegExp(r'\n{3,}');

/// Retire la syntaxe Markdown de [source] pour en faire un extrait lisible.
/// Retourne une chaîne vide si [source] est nulle ou ne contient que de la
/// syntaxe.
String stripMarkdown(String? source) {
  if (source == null || source.trim().isEmpty) return '';
  var text = source;
  text = text.replaceAll(_fenceRegExp, ' ');
  text = text.replaceAll(_imageRegExp, ' ');
  text = text.replaceAllMapped(_linkRegExp, (m) => m[1]!);
  text = text.replaceAllMapped(_boldRegExp, (m) => m[1]!);
  text = text.replaceAllMapped(_boldUnderRegExp, (m) => m[1]!);
  text = text.replaceAllMapped(_italicRegExp, (m) => m[1]!);
  text = text.replaceAllMapped(
    _italicUnderRegExp,
    (m) => '${m[1]}${m[2]}${m[3]}',
  );
  text = text.replaceAllMapped(_strikeRegExp, (m) => m[1]!);
  text = text.replaceAllMapped(_inlineCodeRegExp, (m) => m[1]!);
  text = text.replaceAll(_headingRegExp, '');
  text = text.replaceAll(_blockquoteRegExp, '');
  text = text.replaceAll(_bulletRegExp, '');
  text = text.replaceAll(_listRegExp, '');
  text = text.replaceAll(_ruleRegExp, '');
  text = text.replaceAll(_htmlRegExp, '');
  text = text.replaceAll(_blankRegExp, '');
  text = text.replaceAll(_newlinesRegExp, '\n\n');
  return text.trim();
}
