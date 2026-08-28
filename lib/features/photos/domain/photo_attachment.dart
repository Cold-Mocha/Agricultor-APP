final class PhotoAttachmentInput {
  const PhotoAttachmentInput({
    required this.ownerId,
    required this.aggregateType,
    required this.aggregateId,
    required this.sourcePath,
    required this.mimeType,
  });

  final String ownerId;
  final String aggregateType;
  final String aggregateId;
  final String sourcePath;
  final String mimeType;
}
