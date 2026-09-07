/// Immutable form/list contract, independent of persistence rows.
final class ParcelView {
  const ParcelView({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isArchived,
    this.locality,
  });
  final String id;
  final String name;
  final String? locality;
  final bool isActive;
  final bool isArchived;
}

final class ParcelFormInput {
  const ParcelFormInput({
    required this.ownerId,
    required this.name,
    required this.isActive,
    this.id,
    this.locality,
  });
  final String ownerId;
  final String? id;
  final String name;
  final String? locality;
  final bool isActive;
}
