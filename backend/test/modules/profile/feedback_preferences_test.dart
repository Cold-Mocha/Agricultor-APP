import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late ProviderContainer container;
  late ProfileFacade facade;

  setUp(() {
    final database = createInMemoryDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });
    facade = container.read(profileFacadeProvider);
  });

  test('feedback preferences default to enabled without stored rows', () async {
    expect(
      await facade.watchFeedbackPreferences('owner-1').first,
      const FeedbackPreferences(),
    );
  });

  test('sound and animation preferences persist independently', () async {
    await facade.setSoundEffectsEnabled('owner-1', false);
    expect(
      await facade.watchFeedbackPreferences('owner-1').first,
      const FeedbackPreferences(soundEffectsEnabled: false),
    );

    await facade.setAnimationsEnabled('owner-1', false);
    await facade.setSoundEffectsEnabled('owner-1', true);
    expect(
      await facade.watchFeedbackPreferences('owner-1').first,
      const FeedbackPreferences(animationsEnabled: false),
    );
  });

  test('preferences are scoped to their owner', () async {
    await facade.setSoundEffectsEnabled('owner-1', false);
    expect(
      await facade.watchFeedbackPreferences('owner-2').first,
      const FeedbackPreferences(),
    );
  });
}
