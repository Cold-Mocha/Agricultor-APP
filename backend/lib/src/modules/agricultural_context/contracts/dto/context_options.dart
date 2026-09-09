final class ContextOption {
  const ContextOption({required this.id, required this.name});
  final String id;
  final String name;
}

final class BoundContextSummary {
  const BoundContextSummary({this.parcelName, this.sectorName});
  final String? parcelName;
  final String? sectorName;
}
