import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_navigation_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Más',
    subtitle: 'Organización, respaldo y datos',
    child: ListView(
      key: const PageStorageKey('more-scroll'),
      children: [
        const AgroSectionHeader(
          title: 'Campo',
          subtitle: 'Planificación y consulta del cuaderno agrícola.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        AgroNavigationCard(
          icon: LucideIcons.calendarDays,
          title: 'Temporadas',
          subtitle: 'Ciclos productivos y vigencia',
          onTap: () => context.push(AppRoutes.seasons),
        ),
        AgroNavigationCard(
          icon: LucideIcons.leaf,
          title: 'Catálogo de cultivos',
          subtitle: 'Especies oficiales y personalizadas',
          onTap: () => context.push(AppRoutes.cropCatalog),
        ),
        AgroNavigationCard(
          icon: LucideIcons.history,
          title: 'Historial agrícola',
          subtitle: 'Actividades, cultivos y mediciones',
          onTap: () => context.push(AppRoutes.history),
        ),
        const SizedBox(height: AgroSpacing.lg),
        const AgroSectionHeader(
          title: 'Organización',
          subtitle: 'Avisos para el trabajo en terreno.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        AgroNavigationCard(
          icon: LucideIcons.bell,
          title: 'Recordatorios',
          subtitle: 'Avisos locales de labores',
          onTap: () => context.push(AppRoutes.reminders),
        ),
        const SizedBox(height: AgroSpacing.lg),
        const AgroSectionHeader(
          title: 'Respaldo y datos',
          subtitle: 'Estado de la nube y copias legibles.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        AgroNavigationCard(
          icon: LucideIcons.cloudSync,
          title: 'Sincronización',
          subtitle: 'Pendientes, errores y conflictos',
          onTap: () => context.push(AppRoutes.synchronization),
        ),
        AgroNavigationCard(
          icon: LucideIcons.table,
          title: 'Exportar XLSX',
          subtitle: 'Respaldo legible de tus datos',
          onTap: () => context.push(AppRoutes.export),
        ),
        const SizedBox(height: AgroSpacing.lg),
        const AgroSectionHeader(title: 'Aplicación'),
        const SizedBox(height: AgroSpacing.sm),
        AgroNavigationCard(
          icon: LucideIcons.settings,
          title: 'Configuración',
          subtitle: 'Alcance y opciones disponibles',
          onTap: () => context.push(AppRoutes.settings),
        ),
        const SizedBox(height: AgroSpacing.lg),
      ],
    ),
  );
}
