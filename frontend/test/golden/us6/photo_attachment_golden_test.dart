import 'package:agrocampo/src/app/theme/agro_theme.dart';
import 'package:agrocampo/src/modules/media/presentation/pages/photo_attachment_page.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../backend/test/helpers/in_memory_database.dart';

void main() {
  testWidgets('photo attachment follows the approved system', (tester) async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const PhotoAttachmentPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(PhotoAttachmentPage),
      matchesGoldenFile('photo_attachment.png'),
    );
  });
}
