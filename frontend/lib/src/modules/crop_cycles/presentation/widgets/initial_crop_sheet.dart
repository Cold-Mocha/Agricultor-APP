import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks which crop a freshly drawn quadrant holds and assigns it, opening the
/// quadrant's first season when needed. Returns the chosen crop, or `null`
/// when the farmer postpones the choice.
Future<CropRef?> askInitialCrop(
  BuildContext context,
  WidgetRef ref, {
  required String ownerId,
  required String sectorId,
}) async {
  final controller = ref.read(cropsControllerProvider);
  final crops = await controller.availableCrops(ownerId);
  if (!context.mounted || crops.isEmpty) return null;
  final selected = await showModalBottomSheet<CropRef>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _InitialCropSheet(crops: crops),
  );
  if (selected == null) return null;
  await controller.assignInitialCrop(
    ownerId: ownerId,
    sectorId: sectorId,
    crop: selected,
  );
  return selected;
}

final class _InitialCropSheet extends StatelessWidget {
  const _InitialCropSheet({required this.crops});

  final List<CropRef> crops;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AgroSpacing.md,
              0,
              AgroSpacing.md,
              AgroSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué cultivas en este cuadrante?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AgroSpacing.xxs),
                const Text('Lo dejamos como cultivo vigente desde hoy.'),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final crop in crops)
                  ListTile(
                    minTileHeight: AgroSizes.touchTarget,
                    leading: CropPictogram(
                      asset: crop.iconAsset,
                      colorToken: crop.colorToken,
                    ),
                    title: Text(crop.label),
                    onTap: () => Navigator.pop(context, crop),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AgroSpacing.sm),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ahora no'),
            ),
          ),
        ],
      ),
    ),
  );
}
