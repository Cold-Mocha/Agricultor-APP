import 'package:agrocampo/app/shell/agro_app_shell.dart';
import 'package:agrocampo/features/agro_ai/presentation/agro_ai_page.dart';
import 'package:agrocampo/features/apiary/presentation/apiary_inspection_page.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/login_page.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/crops/presentation/crop_catalog_page.dart';
import 'package:agrocampo/features/crops/presentation/rotation_page.dart';
import 'package:agrocampo/features/export/presentation/export_page.dart';
import 'package:agrocampo/features/history/presentation/history_page.dart';
import 'package:agrocampo/features/home/presentation/home_page.dart';
import 'package:agrocampo/features/irrigation/presentation/irrigation_record_page.dart';
import 'package:agrocampo/features/labors/presentation/labor_form_page.dart';
import 'package:agrocampo/features/map/presentation/territory_map_page.dart';
import 'package:agrocampo/features/more/presentation/more_page.dart';
import 'package:agrocampo/features/parcels/presentation/parcel_form_page.dart';
import 'package:agrocampo/features/parcels/presentation/parcel_list_page.dart';
import 'package:agrocampo/features/photos/presentation/photo_attachment_page.dart';
import 'package:agrocampo/features/production/presentation/production_page.dart';
import 'package:agrocampo/features/profile/presentation/profile_page.dart';
import 'package:agrocampo/features/reminders/presentation/reminders_page.dart';
import 'package:agrocampo/features/sectors/presentation/sector_detail_page.dart';
import 'package:agrocampo/features/sectors/presentation/sector_list_page.dart';
import 'package:agrocampo/features/soil/presentation/soil_measurement_page.dart';
import 'package:agrocampo/features/sync_status/presentation/conflict_resolution_page.dart';
import 'package:agrocampo/features/sync_status/presentation/sync_status_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return GoRouter(
    initialLocation: '/inicio',
    restorationScopeId: 'router',
    redirect: (context, state) {
      final onLogin = state.matchedLocation == '/acceso';
      if (session.status == SessionStatus.checking) {
        return onLogin ? null : '/acceso';
      }
      if (session.status == SessionStatus.signedOut) {
        return onLogin ? null : '/acceso';
      }
      if (onLogin) {
        return '/inicio';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/acceso',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/perfil',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/sincronizacion',
        name: 'sync-status',
        builder: (context, state) => const SyncStatusPage(),
        routes: [
          GoRoute(
            path: 'conflictos/:id',
            builder: (context, state) =>
                ConflictResolutionPage(conflictId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/parcelas',
        builder: (context, state) => const ParcelListPage(),
        routes: [
          GoRoute(
            path: 'nueva',
            builder: (context, state) => const ParcelFormPage(),
          ),
          GoRoute(
            path: ':id/editar',
            builder: (context, state) =>
                ParcelFormPage(parcelId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/mapa',
        builder: (context, state) => const TerritoryMapPage(),
      ),
      GoRoute(
        path: '/cultivos',
        builder: (context, state) => const CropCatalogPage(),
      ),
      GoRoute(
        path: '/suelo',
        builder: (context, state) => const SoilMeasurementPage(),
      ),
      GoRoute(
        path: '/riego',
        builder: (context, state) => const IrrigationRecordPage(),
      ),
      GoRoute(
        path: '/historial',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/produccion',
        builder: (context, state) => const ProductionPage(),
      ),
      GoRoute(
        path: '/fotografias',
        builder: (context, state) => const PhotoAttachmentPage(),
      ),
      GoRoute(
        path: '/recordatorios',
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: '/exportar',
        builder: (context, state) => const ExportPage(),
      ),
      GoRoute(
        path: '/sectores/:id/apicultura',
        builder: (context, state) =>
            ApiaryInspectionPage(sectorId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/sectores/:id/detalle',
        builder: (context, state) =>
            SectorDetailPage(sectorId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/sectores/:id/rotacion',
        builder: (context, state) =>
            RotationPage(sectorId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'main-shell',
        builder: (context, state, navigationShell) =>
            AgroAppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/inicio', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sectores',
                builder: (_, _) => const SectorListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/registrar',
                builder: (_, _) => const LaborFormPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/agroia', builder: (_, _) => const AgroAiPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mas',
                builder: (_, _) => const MorePage(),
                routes: [
                  GoRoute(path: 'perfil', redirect: (_, _) => '/perfil'),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
