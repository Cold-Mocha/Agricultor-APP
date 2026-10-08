enum CropSource { official, custom }

final class CropRef {
  const CropRef({
    required this.id,
    required this.label,
    required this.source,
    this.scientificName,
    this.category,
    this.iconAsset,
    this.colorToken,
    this.archived = false,
  });

  final String id;
  final String label;
  final CropSource source;
  final String? scientificName;
  final String? category;
  final String? iconAsset;
  final String? colorToken;
  final bool archived;

  bool get isCustom => source == CropSource.custom;
}
