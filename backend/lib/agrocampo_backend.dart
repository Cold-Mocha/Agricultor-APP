/// Stable presentation contract. Persistence and transport stay internal.
library;

export 'core/config/app_lifecycle_controller.dart'
    show AppLifecycleController, appLifecycleControllerProvider;
export 'core/config/backend_bootstrap.dart';
export 'core/geometry/geo_point.dart';
export 'features/agro_ai/agro_ai_api.dart';
export 'features/apiary/apiary_api.dart';
export 'features/auth/controllers/session_controller.dart'
    show sessionControllerProvider, unlockedOwnerIdProvider, SessionController;
export 'features/auth/domain/session_state.dart';
export 'features/context/controllers/agricultural_context_controller.dart';
export 'features/context/controllers/context_options_controller.dart';
export 'features/context/domain/agricultural_context.dart';
export 'features/context/dto/context_options.dart';
export 'features/crops/crops_api.dart';
export 'features/export/export_api.dart';
export 'features/history/history_api.dart';
export 'features/irrigation/irrigation_api.dart';
export 'features/labors/labors_api.dart';
export 'features/map/map_api.dart';
export 'features/parcels/controllers/parcel_controller.dart';
export 'features/parcels/dto/parcel_view.dart';
export 'features/photos/photos_api.dart';
export 'features/production/production_api.dart';
export 'features/profile/profile_api.dart';
export 'features/reminders/reminders_api.dart';
export 'features/sectors/controllers/sector_detail_controller.dart';
export 'features/sectors/controllers/sector_list_controller.dart';
export 'features/sectors/dto/sector_ui_state.dart';
export 'features/soil/soil_api.dart';
export 'features/sync_status/sync_status_api.dart';
export 'features/weather/weather_api.dart';
export 'shared/contracts/app_routes.dart';
