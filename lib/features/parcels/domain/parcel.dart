final class Parcel {
  const Parcel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.updatedAt,
    this.locality,
    this.isActive = false,
    this.isArchived = false,
    this.version = 1,
  });

  final String id;
  final String ownerId;
  final String name;
  final String? locality;
  final bool isActive;
  final bool isArchived;
  final int version;
  final DateTime updatedAt;
}
