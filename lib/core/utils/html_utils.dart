String decodeHtmlEntities(String text) {
  if (text.isEmpty) return text;

  var result = text;
  const entities = {
    '&ccedil;': 'ç',
    '&Ccedil;': 'Ç',
    '&ouml;': 'ö',
    '&Ouml;': 'Ö',
    '&uuml;': 'ü',
    '&Uuml;': 'Ü',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&nbsp;': ' ',
    '&quot;': '"',
    '&apos;': '\'',
    '&mdash;': '-',
  };

  for (final entry in entities.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }

  result = result.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) => String.fromCharCode(int.parse(match[1]!)),
  );
  result = result.replaceAllMapped(
    RegExp(r'&#x([0-9a-fA-F]+);'),
    (match) => String.fromCharCode(int.parse(match[1]!, radix: 16)),
  );

  return result;
}

String htmlToPlainText(String html) {
  if (html.isEmpty) return '';

  var result = decodeHtmlEntities(html);
  result = result.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  result = result.replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n');
  result = result.replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n');
  result = result.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ');
  result = result.replaceAll(RegExp(r'<[^>]+>'), '');
  result = result.replaceAll('\u00A0', ' ');

  final normalized = result
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');

  return normalized;
}
