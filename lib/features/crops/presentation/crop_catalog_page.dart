import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/crops/data/crop_seed_loader.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

final class CropCatalogPage extends ConsumerWidget {
  const CropCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Catálogo de cultivos',
      subtitle: 'Catálogo oficial y cultivos propios',
      child: FutureBuilder(
        future: CropSeedLoader(database).seedIfEmpty(),
        builder: (context, seed) => StreamBuilder(
          stream: database.select(database.officialCrops).watch(),
          builder: (context, snapshot) {
            final crops = snapshot.data ?? const [];
            if (crops.isEmpty) {
              return const AgroEmptyState(
                title: 'Cargando catálogo',
                message: 'El catálogo local estará disponible enseguida.',
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                childAspectRatio: 1.8,
              ),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return Card(
                  child: ListTile(
                    leading: SvgPicture.asset(
                      crop.iconAsset,
                      width: 36,
                      height: 36,
                    ),
                    title: Text(crop.commonName),
                    subtitle: Text(crop.scientificName ?? crop.category),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
