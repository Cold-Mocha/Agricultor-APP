import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/shell/agro_app_shell.dart';
import 'package:agrocampo/src/app/shell/more_page.dart';
import 'package:agrocampo/src/modules/agro_ai/agro_ai_ui.dart';
import 'package:agrocampo/src/modules/apiary/apiary_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/crop_cycles_ui.dart';
import 'package:agrocampo/src/modules/export/export_ui.dart';
import 'package:agrocampo/src/modules/history/history_ui.dart';
import 'package:agrocampo/src/modules/home/home_ui.dart';
import 'package:agrocampo/src/modules/irrigation/irrigation_ui.dart';
import 'package:agrocampo/src/modules/labors/labors_ui.dart';
import 'package:agrocampo/src/modules/media/media_ui.dart';
import 'package:agrocampo/src/modules/production/production_ui.dart';
import 'package:agrocampo/src/modules/profile/profile_ui.dart';
import 'package:agrocampo/src/modules/reminders/reminders_ui.dart';
import 'package:agrocampo/src/modules/soil/soil_ui.dart';
import 'package:agrocampo/src/modules/territory/territory_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
      // Records open full screen from a quadrant; they are no longer a tab.
      GoRoute(
        path: AppRoutes.register,
        builder: (_, state) => LaborFormPage(
          initialSectorId: state.uri.queryParameters['sectorId'],
        ),
        routes: [
          GoRoute(
            path: 'labor/editar/:id',
            builder: (_, state) =>
                LaborFormPage(editLaborId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'labor/:laborType',
            builder: (_, state) => LaborFormPage(
              initialSectorId: state.uri.queryParameters['sectorId'],
              initialLaborType: _laborType(state.pathParameters['laborType']),
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
                  initialSectorId: state.uri.queryParameters['sectorId'],
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
                    path: 'mapa',
                    // Full screen: the map opens above the bottom navigation.
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const TerritoryMapPage(),
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
                    path: 'perfil',
                    builder: (_, _) => const ProfilePage(),
                    routes: [
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
                        builder: (_, _) => const ProfileThemePage(),
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
