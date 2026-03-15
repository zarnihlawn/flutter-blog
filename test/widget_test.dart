import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blog/theme/brutal_theme.dart';

void main() {
  test('Brutal theme applies app bar style', () {
    final theme = buildBrutalTheme();
    expect(theme.appBarTheme.backgroundColor, equals(const Color(0xFFFFD400)));
  });
}
