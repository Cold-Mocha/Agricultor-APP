import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks which crop a quadrant about to be created holds. Returns `null` when
/// the farmer cancels; the quadrant must then not be created.
Future<CropRef?> pickInitialCrop(
  BuildContext context,
  WidgetRef ref, {
  required String ownerId,
  String title = '¿Qué cultivas en este cuadrante?',
  String message = 'Lo dejamos como cultivo vigente desde hoy.',
}) async {
  final crops = await ref.read(cropsControllerProvider).availableCrops(ownerId);
  if (!context.mounted || crops.isEmpty) return null;
  return showModalBottomSheet<CropRef>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _InitialCropSheet(crops: crops, title: title, message: message),
  );
}

final class _InitialCropSheet extends StatelessWidget {
  const _InitialCropSheet({
    required this.crops,
    required this.title,
    required this.message,
  });

  final List<CropRef> crops;
  final String title;
  final String message;

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
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AgroSpacing.xxs),
                Text(message),
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
                      apiary: crop.id == CropPictogram.apiaryCropId,
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
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    ),
  );
}
