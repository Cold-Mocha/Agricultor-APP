import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

final class AndroidSafExporter {
  const AndroidSafExporter();
  static const _channel = MethodChannel('cl.agrocampo.app/export');

  Future<bool> save(List<int> bytes, String suggestedName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$suggestedName');
    await file.writeAsBytes(bytes, flush: true);
    return await _channel.invokeMethod<bool>('saveXlsx', {
          'sourcePath': file.path,
          'suggestedName': suggestedName,
        }) ??
        false;
  }
}
