import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Material theme is backed by the AgroCampo token palette', () {
    final theme = AgroTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AgroColors.brand);
    expect(theme.colorScheme.secondary, AgroColors.accent);
    expect(theme.extension<AgroSemanticColors>(), isNotNull);
  });
}
