import 'package:flutter_test/flutter_test.dart';

import 'package:surdotv_app/core/utils/html_utils.dart';

void main() {
  test('htmlToPlainText strips tags and decodes entities', () {
    const input =
        '<p>M&ouml;c&uuml;zə</p><ul><li>Birinci</li><li>İkinci</li></ul>';

    final output = htmlToPlainText(input);

    expect(output, 'Möcüzə\n• Birinci\n• İkinci');
  });
}
