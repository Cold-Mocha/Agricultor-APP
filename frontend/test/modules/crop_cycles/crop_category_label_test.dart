import 'package:agrocampo/src/modules/crop_cycles/presentation/formatters/crop_category_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps catalog category codes to Spanish labels', () {
    expect(cropCategoryLabel('berry'), 'Berries');
    expect(cropCategoryLabel('tuberculo'), 'Tubérculo');
    expect(cropCategoryLabel('frutal'), 'Frutal');
  });

  test('keeps unknown codes and hides missing ones', () {
    expect(cropCategoryLabel('Legumbre'), 'Legumbre');
    expect(cropCategoryLabel(null), '');
  });
}
