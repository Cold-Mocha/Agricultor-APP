final class AgroExportSnapshot {
  const AgroExportSnapshot({
    required this.generatedAt,
    required this.sheets,
    this.id = '',
    this.columns = const {},
  });
  final String id;
  final DateTime generatedAt;
  final Map<String, List<Map<String, Object?>>> sheets;
  final Map<String, List<String>> columns;
}
