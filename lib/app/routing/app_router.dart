import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/shell/agro_app_shell.dart';
import 'package:agrocampo/features/agro_ai/presentation/agro_ai_page.dart';
import 'package:agrocampo/features/apiary/presentation/apiary_inspection_page.dart';
import 'package:agrocampo/features/auth/domain/session_state.dart';
import 'package:agrocampo/features/auth/presentation/login_page.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/crops/presentation/agricultural_season_form_page.dart';
import 'package:agrocampo/features/crops/presentation/agricultural_seasons_page.dart';
import 'package:agrocampo/features/crops/presentation/crop_catalog_page.dart';
import 'package:agrocampo/features/crops/presentation/rotation_page.dart';
import 'package:agrocampo/features/export/presentation/export_page.dart';
import 'package:agrocampo/features/history/presentation/history_page.dart';
import 'package:agrocampo/features/home/presentation/home_page.dart';
import 'package:agrocampo/features/irrigation/presentation/drip_configuration_page.dart';
import 'package:agrocampo/features/irrigation/presentation/irrigation_record_page.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/presentation/labor_form_page.dart';
import 'package:agrocampo/features/map/presentation/territory_map_page.dart';
import 'package:agrocampo/features/more/presentation/more_page.dart';
import 'package:agrocampo/features/parcels/presentation/parcel_form_page.dart';
import 'package:agrocampo/features/parcels/presentation/parcel_list_page.dart';
import 'package:agrocampo/features/photos/presentation/photo_attachment_page.dart';
import 'package:agrocampo/features/production/presentation/production_page.dart';
import 'package:agrocampo/features/profile/presentation/profile_page.dart';
import 'package:agrocampo/features/profile/presentation/profile_settings_pages.dart';
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
    initialLocation: AppRoutes.home,
    restorationScopeId: 'router',
    redirect: (context, state) {
      final onLogin = state.matchedLocation == AppRoutes.login;
      if (session.status == SessionStatus.restoring ||
          session.status == SessionStatus.locked ||
          session.status == SessionStatus.signedOut) {
        return onLogin ? null : AppRoutes.login;
      }
      if (onLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // Notification payload compatibility for records made before the
      // navigation hierarchy was corrected.
      GoRoute(
        path: '/recordatorios/:id',
        redirect: (context, state) =>
            '${AppRoutes.reminders}/${state.pathParameters['id']!}',
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'main-shell',
        builder: (context, state, navigationShell) =>
            AgroAppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'perfil',
                    builder: (_, _) => const ProfilePage(),
                    routes: [
                      GoRoute(
                        path: 'informacion',
                        builder: (_, _) =>
                            const ProfilePersonalInformationPage(),
                      ),
                      GoRoute(
                        path: 'notificaciones',
                        builder: (_, _) => const ProfileNotificationsPage(),
                      ),
                      GoRoute(
                        path: 'idioma',
                        builder: (_, _) => const ProfileInformationPage(
                          kind: ProfileInformationKind.language,
                        ),
                      ),
                      GoRoute(
                        path: 'seguridad',
                        builder: (_, _) => const ProfileSecurityPage(),
                      ),
                      GoRoute(
                        path: 'tema',
                        builder: (_, _) => const ProfileInformationPage(
                          kind: ProfileInformationKind.theme,
                        ),
                      ),
                      GoRoute(
                        path: 'ayuda',
                        builder: (_, _) => const ProfileInformationPage(
                          kind: ProfileInformationKind.help,
                        ),
                      ),
                      GoRoute(
                        path: 'contacto',
                        builder: (_, _) => const ProfileInformationPage(
                          kind: ProfileInformationKind.contact,
                        ),
                      ),
                      GoRoute(
                        path: 'privacidad',
                        builder: (_, _) => const ProfileInformationPage(
                          kind: ProfileInformationKind.privacy,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'parcelas',
                    builder: (_, _) => const ParcelListPage(),
                    routes: [
                      GoRoute(
                        path: 'nueva',
                        builder: (_, _) => const ParcelFormPage(),
                      ),
                      GoRoute(
                        path: ':id/editar',
                        builder: (_, state) => ParcelFormPage(
                          parcelId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sectors,
                builder: (_, _) => const SectorListPage(),
                routes: [
                  GoRoute(
                    path: 'parcela/:parcelId/mapa',
                    builder: (_, state) => TerritoryMapPage(
                      initialParcelId: state.pathParameters['parcelId'],
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        SectorDetailPage(sectorId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'rotacion',
                        builder: (_, state) =>
                            RotationPage(sectorId: state.pathParameters['id']!),
                      ),
                      GoRoute(
                        path: 'historial',
                        builder: (_, state) => HistoryPage(
                          initialSectorId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'apicultura',
                        builder: (_, state) => ApiaryInspectionPage(
                          sectorId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.register,
                builder: (_, state) => LaborFormPage(
                  initialSectorId: state.uri.queryParameters['sectorId'],
                ),
                routes: [
                  GoRoute(
                    path: 'labor/:laborType',
                    builder: (_, state) => LaborFormPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                      initialLaborType: _laborType(
                        state.pathParameters['laborType'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'suelo',
                    builder: (_, state) => SoilMeasurementPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                    ),
                  ),
                  GoRoute(
                    path: 'riego',
                    builder: (_, state) => IrrigationRecordPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'configuracion',
                        builder: (_, state) => DripConfigurationPage(
                          initialSectorId:
                              state.uri.queryParameters['sectorId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'produccion',
                    builder: (_, state) => ProductionPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                    ),
                  ),
                  GoRoute(
                    path: 'foto',
                    builder: (_, state) => PhotoAttachmentPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.agroAi,
                builder: (_, _) => const AgroAiPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (_, _) => const MorePage(),
                routes: [
                  GoRoute(
                    path: 'temporadas',
                    builder: (_, _) => const AgriculturalSeasonsPage(),
                    routes: [
                      GoRoute(
                        path: 'nueva',
                        builder: (_, _) => const AgriculturalSeasonFormPage(),
                      ),
                      GoRoute(
                        path: ':id/editar',
                        builder: (_, state) => AgriculturalSeasonFormPage(
                          seasonId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'catalogo',
                    builder: (_, _) => const CropCatalogPage(),
                  ),
                  GoRoute(
                    path: 'historial',
                    builder: (_, state) => HistoryPage(
                      initialSectorId: state.uri.queryParameters['sectorId'],
                    ),
                  ),
                  GoRoute(
                    path: 'recordatorios',
                    builder: (_, _) => const RemindersPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, _) => const RemindersPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'sincronizacion',
                    name: 'sync-status',
                    builder: (_, _) => const SyncStatusPage(),
                    routes: [
                      GoRoute(
                        path: 'conflictos/:id',
                        builder: (_, state) => ConflictResolutionPage(
                          conflictId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'exportar',
                    builder: (_, _) => const ExportPage(),
                  ),
                  GoRoute(
                    path: 'configuracion',
                    builder: (_, _) => const GeneralSettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

LaborType? _laborType(String? value) {
  for (final type in LaborType.values) {
    if (type.name == value) return type;
  }
  return null;
}
