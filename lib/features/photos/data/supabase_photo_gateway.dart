import 'dart:typed_data';

import 'package:agrocampo/features/photos/data/photo_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class SupabasePhotoGateway implements PhotoUploadGateway {
  const SupabasePhotoGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<String> upload({
    required String ownerId,
    required String contentHash,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final remotePath = '$ownerId/$contentHash';
    try {
      await _client.storage
          .from('photos')
          .uploadBinary(
            remotePath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );
    } on StorageException catch (error) {
      if (error.statusCode != '409') rethrow;
    }
    return remotePath;
  }
}
