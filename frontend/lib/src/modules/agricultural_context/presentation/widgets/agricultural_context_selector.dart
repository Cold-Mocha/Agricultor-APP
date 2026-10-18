import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/presentation/controllers/agricultural_context_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class AgriculturalContextSelector extends ConsumerWidget {
  const AgriculturalContextSelector({
    this.requireSector = false,
    this.compact = false,
    super.key,
  });

  final bool requireSector;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final controller = ref.watch(contextOptionsControllerProvider);
    final ownerId = agriculturalContext.ownerId;
    if (ownerId == null) return const SizedBox.shrink();
    return StreamBuilder(
      stream: controller.watchSectors(ownerId),
      builder: (context, sectorSnapshot) {
        final sectors = sectorSnapshot.data ?? const [];
        return Semantics(
          label: 'Contexto agrícola activo',
          container: true,
          child: Padding(
            padding: const EdgeInsets.only(top: AgroSpacing.xs),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _selector(
                  key: const Key('active-sector-selector'),
                  initialValue:
                      sectors.any(
                        (row) => row.id == agriculturalContext.sectorId,
                      )
                      ? agriculturalContext.sectorId
                      : null,
                  label: requireSector ? 'Sector requerido' : 'Sector',
                  hint: sectors.isEmpty
                      ? 'Aún no hay cuadrantes'
                      : 'Selecciona un sector',
                  icon: LucideIcons.layoutGrid,
                  showLeadingIcon: true,
                  items: [
                    for (final sector in sectors)
                      DropdownMenuItem(
                        value: sector.id,
                        child: Text(
                          sector.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => ref
                      .read(agriculturalContextControllerProvider.notifier)
                      .selectSector(value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _selector({
    required Key key,
    required String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    required bool showLeadingIcon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) => DropdownButtonFormField<String>(
    key: key,
    isExpanded: true,
    initialValue: initialValue,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: showLeadingIcon ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AgroSpacing.sm,
        vertical: AgroSpacing.sm,
      ),
    ),
    hint: Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis),
    items: items,
    onChanged: onChanged,
  );
}
