final class AgroExportSnapshot {
  const AgroExportSnapshot({required this.generatedAt, required this.sheets});
  final DateTime generatedAt;
  final Map<String, List<Map<String, Object?>>> sheets;
}
