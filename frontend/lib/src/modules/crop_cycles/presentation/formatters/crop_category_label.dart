/// Display label for the catalog category codes in crop_catalog_v1.json.
/// Unknown codes, such as custom categories, are shown unchanged.
String cropCategoryLabel(String? code) => switch (code) {
  null || '' => '',
  'berry' => 'Berries',
  'tuberculo' => 'Tubérculo',
  'frutal' => 'Frutal',
  'hortaliza' => 'Hortaliza',
  'cereal' => 'Cereal',
  'apicultura' => 'Apicultura',
  _ => code,
};
