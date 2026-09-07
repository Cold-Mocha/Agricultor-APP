# Inventario físico de la migración

Se movieron 424 archivos inventariados y el directorio Android completo (19 archivos nativos versionados). Los hashes iniciales están en [migration-manifest.json](./migration-manifest.json). Se conservaron archivos locales ignorados.

## Archivos movidos

| Origen | Destino final |
|---|---|
| `lib/app/agro_campo_app.dart` | `frontend/lib/app/agro_campo_app.dart` |
| `lib/app/bootstrap/app_bootstrap.dart` | `frontend/lib/app/bootstrap/app_bootstrap.dart` |
| `lib/app/bootstrap/app_environment.dart` | `backend/lib/core/config/app_environment.dart` |
| `lib/app/providers.dart` | `backend/lib/core/config/backend_providers.dart` |
| `lib/app/routing/app_router.dart` | `frontend/lib/app/routing/app_router.dart` |
| `lib/app/routing/app_routes.dart` | `backend/lib/shared/contracts/app_routes.dart` |
| `lib/app/shell/agro_app_shell.dart` | `frontend/lib/app/shell/agro_app_shell.dart` |
| `lib/app/shell/agro_global_sync_status.dart` | `frontend/lib/app/shell/agro_global_sync_status.dart` |
| `lib/app/theme/agro_theme.dart` | `frontend/lib/app/theme/agro_theme.dart` |
| `lib/app/theme/agro_tokens.dart` | `frontend/lib/app/theme/agro_tokens.dart` |
| `lib/app/theme/asset_catalog.dart` | `frontend/lib/app/theme/asset_catalog.dart` |
| `lib/core/auth/auth_repository.dart` | `backend/lib/core/auth/auth_repository.dart` |
| `lib/core/auth/biometric_unlock_gateway.dart` | `backend/lib/core/auth/biometric_unlock_gateway.dart` |
| `lib/core/auth/secure_session_store.dart` | `backend/lib/core/auth/secure_session_store.dart` |
| `lib/core/database/app_database.dart` | `backend/lib/core/database/app_database.dart` |
| `lib/core/database/app_database.g.dart` | `backend/lib/core/database/app_database.g.dart` |
| `lib/core/database/daos/app_preferences_dao.dart` | `backend/lib/core/database/daos/app_preferences_dao.dart` |
| `lib/core/database/daos/conflict_dao.dart` | `backend/lib/core/database/daos/conflict_dao.dart` |
| `lib/core/database/daos/conflict_dao.g.dart` | `backend/lib/core/database/daos/conflict_dao.g.dart` |
| `lib/core/database/daos/form_draft_dao.dart` | `backend/lib/core/database/daos/form_draft_dao.dart` |
| `lib/core/database/daos/form_draft_dao.g.dart` | `backend/lib/core/database/daos/form_draft_dao.g.dart` |
| `lib/core/database/daos/sync_cursor_dao.dart` | `backend/lib/core/database/daos/sync_cursor_dao.dart` |
| `lib/core/database/daos/sync_cursor_dao.g.dart` | `backend/lib/core/database/daos/sync_cursor_dao.g.dart` |
| `lib/core/database/daos/sync_outbox_dao.dart` | `backend/lib/core/database/daos/sync_outbox_dao.dart` |
| `lib/core/database/daos/sync_outbox_dao.g.dart` | `backend/lib/core/database/daos/sync_outbox_dao.g.dart` |
| `lib/core/database/migrations/functional_core_v10.dart` | `backend/lib/core/database/migrations/functional_core_v10.dart` |
| `lib/core/database/migrations/migration_policy.dart` | `backend/lib/core/database/migrations/migration_policy.dart` |
| `lib/core/database/tables/apiary_inspection_table.dart` | `backend/lib/core/database/tables/apiary_inspection_table.dart` |
| `lib/core/database/tables/crop_irrigation_rule_table.dart` | `backend/lib/core/database/tables/crop_irrigation_rule_table.dart` |
| `lib/core/database/tables/external_service_tables.dart` | `backend/lib/core/database/tables/external_service_tables.dart` |
| `lib/core/database/tables/irrigation_estimate_table.dart` | `backend/lib/core/database/tables/irrigation_estimate_table.dart` |
| `lib/core/database/tables/labor_tables.dart` | `backend/lib/core/database/tables/labor_tables.dart` |
| `lib/core/database/tables/media_reminder_tables.dart` | `backend/lib/core/database/tables/media_reminder_tables.dart` |
| `lib/core/database/tables/parcel_table.dart` | `backend/lib/core/database/tables/parcel_table.dart` |
| `lib/core/database/tables/production_table.dart` | `backend/lib/core/database/tables/production_table.dart` |
| `lib/core/database/tables/technical_tables.dart` | `backend/lib/core/database/tables/technical_tables.dart` |
| `lib/core/database/tables/territory_tables.dart` | `backend/lib/core/database/tables/territory_tables.dart` |
| `lib/core/errors/app_failure.dart` | `backend/lib/core/errors/app_failure.dart` |
| `lib/core/export/android_saf_exporter.dart` | `backend/lib/core/export/android_saf_exporter.dart` |
| `lib/core/export/export_snapshot.dart` | `backend/lib/core/export/export_snapshot.dart` |
| `lib/core/export/xlsx_exporter.dart` | `backend/lib/core/export/xlsx_exporter.dart` |
| `lib/core/files/private_file_store.dart` | `backend/lib/core/files/private_file_store.dart` |
| `lib/core/geometry/geo_point.dart` | `backend/lib/core/geometry/geo_point.dart` |
| `lib/core/geometry/polygon_geometry.dart` | `backend/lib/core/geometry/polygon_geometry.dart` |
| `lib/core/network/connectivity_service.dart` | `backend/lib/core/network/connectivity_service.dart` |
| `lib/core/network/runtime_config.dart` | `backend/lib/core/network/runtime_config.dart` |
| `lib/core/notifications/fcm_gateway.dart` | `backend/lib/core/notifications/fcm_gateway.dart` |
| `lib/core/notifications/local_notification_scheduler.dart` | `backend/lib/core/notifications/local_notification_scheduler.dart` |
| `lib/core/notifications/reminder_reconciler.dart` | `backend/lib/core/notifications/reminder_reconciler.dart` |
| `lib/core/observability/safe_logger.dart` | `backend/lib/core/observability/safe_logger.dart` |
| `lib/core/sync/conflicts/conflict_resolver.dart` | `backend/lib/core/sync/conflicts/conflict_resolver.dart` |
| `lib/core/sync/protocol/aggregate_sync_codec.dart` | `backend/lib/core/sync/protocol/aggregate_sync_codec.dart` |
| `lib/core/sync/protocol/aggregate_sync_registry.dart` | `backend/lib/core/sync/protocol/aggregate_sync_registry.dart` |
| `lib/core/sync/protocol/agricultural_season_sync_codec.dart` | `backend/lib/core/sync/protocol/agricultural_season_sync_codec.dart` |
| `lib/core/sync/protocol/custom_crop_sync_codec.dart` | `backend/lib/core/sync/protocol/custom_crop_sync_codec.dart` |
| `lib/core/sync/protocol/irrigation_sync_codec.dart` | `backend/lib/core/sync/protocol/irrigation_sync_codec.dart` |
| `lib/core/sync/protocol/labor_sync_codec.dart` | `backend/lib/core/sync/protocol/labor_sync_codec.dart` |
| `lib/core/sync/protocol/parcel_sync_codec.dart` | `backend/lib/core/sync/protocol/parcel_sync_codec.dart` |
| `lib/core/sync/protocol/reminder_sync_codec.dart` | `backend/lib/core/sync/protocol/reminder_sync_codec.dart` |
| `lib/core/sync/protocol/sector_crop_assignment_sync_codec.dart` | `backend/lib/core/sync/protocol/sector_crop_assignment_sync_codec.dart` |
| `lib/core/sync/protocol/sector_sync_codec.dart` | `backend/lib/core/sync/protocol/sector_sync_codec.dart` |
| `lib/core/sync/protocol/supabase_sync_gateway.dart` | `backend/lib/core/sync/protocol/supabase_sync_gateway.dart` |
| `lib/core/sync/protocol/sync_contract.dart` | `backend/lib/core/sync/protocol/sync_contract.dart` |
| `lib/core/sync/protocol/sync_pull_response_parser.dart` | `backend/lib/core/sync/protocol/sync_pull_response_parser.dart` |
| `lib/core/sync/protocol/sync_push_response_parser.dart` | `backend/lib/core/sync/protocol/sync_push_response_parser.dart` |
| `lib/core/sync/sync_coordinator.dart` | `backend/lib/core/sync/sync_coordinator.dart` |
| `lib/core/sync/sync_gateway.dart` | `backend/lib/core/sync/sync_gateway.dart` |
| `lib/core/sync/sync_request_hash.dart` | `backend/lib/core/sync/sync_request_hash.dart` |
| `lib/core/sync/sync_retry_policy.dart` | `backend/lib/core/sync/sync_retry_policy.dart` |
| `lib/core/sync/sync_scheduler.dart` | `backend/lib/core/sync/sync_scheduler.dart` |
| `lib/core/sync/sync_state.dart` | `backend/lib/core/sync/sync_state.dart` |
| `lib/core/sync/sync_trigger_coordinator.dart` | `backend/lib/core/sync/sync_trigger_coordinator.dart` |
| `lib/features/agro_ai/data/agro_ai_gateway.dart` | `backend/lib/features/agro_ai/repositories/agro_ai_gateway.dart` |
| `lib/features/agro_ai/data/agro_ai_repository.dart` | `backend/lib/features/agro_ai/repositories/agro_ai_repository.dart` |
| `lib/features/agro_ai/domain/agro_ai_message.dart` | `backend/lib/features/agro_ai/domain/agro_ai_message.dart` |
| `lib/features/agro_ai/presentation/agro_ai_page.dart` | `frontend/lib/features/agro_ai/presentation/agro_ai_page.dart` |
| `lib/features/apiary/data/apiary_repository.dart` | `backend/lib/features/apiary/repositories/apiary_repository.dart` |
| `lib/features/apiary/domain/apiary_inspection_input.dart` | `backend/lib/features/apiary/domain/apiary_inspection_input.dart` |
| `lib/features/apiary/presentation/apiary_inspection_page.dart` | `frontend/lib/features/apiary/presentation/apiary_inspection_page.dart` |
| `lib/features/auth/domain/session_state.dart` | `backend/lib/features/auth/domain/session_state.dart` |
| `lib/features/auth/presentation/login_page.dart` | `frontend/lib/features/auth/presentation/login_page.dart` |
| `lib/features/auth/presentation/session_controller.dart` | `backend/lib/features/auth/controllers/session_controller.dart` |
| `lib/features/context/domain/agricultural_context.dart` | `backend/lib/features/context/domain/agricultural_context.dart` |
| `lib/features/context/presentation/agricultural_context_controller.dart` | `backend/lib/features/context/controllers/agricultural_context_controller.dart` |
| `lib/features/crops/data/agricultural_season_repository.dart` | `backend/lib/features/crops/repositories/agricultural_season_repository.dart` |
| `lib/features/crops/data/crop_assignment_reconciler.dart` | `backend/lib/features/crops/repositories/crop_assignment_reconciler.dart` |
| `lib/features/crops/data/crop_exchange_repository.dart` | `backend/lib/features/crops/repositories/crop_exchange_repository.dart` |
| `lib/features/crops/data/crop_repository.dart` | `backend/lib/features/crops/repositories/crop_repository.dart` |
| `lib/features/crops/data/crop_seed_loader.dart` | `backend/lib/features/crops/repositories/crop_seed_loader.dart` |
| `lib/features/crops/data/sector_crop_assignment_repository.dart` | `backend/lib/features/crops/repositories/sector_crop_assignment_repository.dart` |
| `lib/features/crops/domain/agricultural_season.dart` | `backend/lib/features/crops/domain/agricultural_season.dart` |
| `lib/features/crops/domain/crop_ref.dart` | `backend/lib/features/crops/domain/crop_ref.dart` |
| `lib/features/crops/domain/crop_rotation.dart` | `backend/lib/features/crops/domain/crop_rotation.dart` |
| `lib/features/crops/domain/sector_crop_assignment.dart` | `backend/lib/features/crops/domain/sector_crop_assignment.dart` |
| `lib/features/crops/presentation/agricultural_seasons_page.dart` | `frontend/lib/features/crops/presentation/agricultural_seasons_page.dart` |
| `lib/features/crops/presentation/agricultural_season_form_page.dart` | `frontend/lib/features/crops/presentation/agricultural_season_form_page.dart` |
| `lib/features/crops/presentation/crop_catalog_page.dart` | `frontend/lib/features/crops/presentation/crop_catalog_page.dart` |
| `lib/features/crops/presentation/rotation_page.dart` | `frontend/lib/features/crops/presentation/rotation_page.dart` |
| `lib/features/export/data/export_repository.dart` | `backend/lib/features/export/repositories/export_repository.dart` |
| `lib/features/export/presentation/export_page.dart` | `frontend/lib/features/export/presentation/export_page.dart` |
| `lib/features/history/data/history_repository.dart` | `backend/lib/features/history/repositories/history_repository.dart` |
| `lib/features/history/data/sector_history_dao.dart` | `backend/lib/features/history/repositories/sector_history_dao.dart` |
| `lib/features/history/domain/history_event.dart` | `backend/lib/features/history/domain/history_event.dart` |
| `lib/features/history/presentation/history_page.dart` | `frontend/lib/features/history/presentation/history_page.dart` |
| `lib/features/home/presentation/home_page.dart` | `frontend/lib/features/home/presentation/home_page.dart` |
| `lib/features/irrigation/data/irrigation_estimate_repository.dart` | `backend/lib/features/irrigation/repositories/irrigation_estimate_repository.dart` |
| `lib/features/irrigation/data/irrigation_repository.dart` | `backend/lib/features/irrigation/repositories/irrigation_repository.dart` |
| `lib/features/irrigation/data/sector_irrigation_config_repository.dart` | `backend/lib/features/irrigation/repositories/sector_irrigation_config_repository.dart` |
| `lib/features/irrigation/domain/irrigation_calculator.dart` | `backend/lib/features/irrigation/domain/irrigation_calculator.dart` |
| `lib/features/irrigation/domain/irrigation_explanation.dart` | `backend/lib/features/irrigation/domain/irrigation_explanation.dart` |
| `lib/features/irrigation/domain/irrigation_record.dart` | `backend/lib/features/irrigation/domain/irrigation_record.dart` |
| `lib/features/irrigation/domain/irrigation_rule_set.dart` | `backend/lib/features/irrigation/domain/irrigation_rule_set.dart` |
| `lib/features/irrigation/domain/sector_irrigation_config.dart` | `backend/lib/features/irrigation/domain/sector_irrigation_config.dart` |
| `lib/features/irrigation/presentation/drip_configuration_page.dart` | `frontend/lib/features/irrigation/presentation/drip_configuration_page.dart` |
| `lib/features/irrigation/presentation/irrigation_record_page.dart` | `frontend/lib/features/irrigation/presentation/irrigation_record_page.dart` |
| `lib/features/labors/data/labor_repository.dart` | `backend/lib/features/labors/repositories/labor_repository.dart` |
| `lib/features/labors/domain/fertilization_details.dart` | `backend/lib/features/labors/domain/fertilization_details.dart` |
| `lib/features/labors/domain/harvest_details.dart` | `backend/lib/features/labors/domain/harvest_details.dart` |
| `lib/features/labors/domain/irrigation_labor_details.dart` | `backend/lib/features/labors/domain/irrigation_labor_details.dart` |
| `lib/features/labors/domain/labor_details.dart` | `backend/lib/features/labors/domain/labor_details.dart` |
| `lib/features/labors/domain/labor_type.dart` | `backend/lib/features/labors/domain/labor_type.dart` |
| `lib/features/labors/domain/other_labor_details.dart` | `backend/lib/features/labors/domain/other_labor_details.dart` |
| `lib/features/labors/domain/phytosanitary_details.dart` | `backend/lib/features/labors/domain/phytosanitary_details.dart` |
| `lib/features/labors/domain/pruning_details.dart` | `backend/lib/features/labors/domain/pruning_details.dart` |
| `lib/features/labors/domain/sowing_details.dart` | `backend/lib/features/labors/domain/sowing_details.dart` |
| `lib/features/labors/presentation/labor_form_page.dart` | `frontend/lib/features/labors/presentation/labor_form_page.dart` |
| `lib/features/map/data/location_gateway.dart` | `backend/lib/features/map/repositories/location_gateway.dart` |
| `lib/features/map/data/places_gateway.dart` | `backend/lib/features/map/repositories/places_gateway.dart` |
| `lib/features/map/domain/sector_geometry_draft.dart` | `backend/lib/features/map/domain/sector_geometry_draft.dart` |
| `lib/features/map/presentation/territory_map_page.dart` | `frontend/lib/features/map/presentation/territory_map_page.dart` |
| `lib/features/more/presentation/more_page.dart` | `frontend/lib/features/more/presentation/more_page.dart` |
| `lib/features/parcels/data/parcel_repository.dart` | `backend/lib/features/parcels/repositories/parcel_repository.dart` |
| `lib/features/parcels/domain/parcel.dart` | `backend/lib/features/parcels/domain/parcel.dart` |
| `lib/features/parcels/presentation/parcel_form_page.dart` | `frontend/lib/features/parcels/presentation/parcel_form_page.dart` |
| `lib/features/parcels/presentation/parcel_list_page.dart` | `frontend/lib/features/parcels/presentation/parcel_list_page.dart` |
| `lib/features/photos/data/photo_repository.dart` | `backend/lib/features/photos/repositories/photo_repository.dart` |
| `lib/features/photos/data/supabase_photo_gateway.dart` | `backend/lib/features/photos/repositories/supabase_photo_gateway.dart` |
| `lib/features/photos/domain/photo_attachment.dart` | `backend/lib/features/photos/domain/photo_attachment.dart` |
| `lib/features/photos/presentation/photo_attachment_page.dart` | `frontend/lib/features/photos/presentation/photo_attachment_page.dart` |
| `lib/features/production/data/production_repository.dart` | `backend/lib/features/production/repositories/production_repository.dart` |
| `lib/features/production/domain/harvest_input.dart` | `backend/lib/features/production/domain/harvest_input.dart` |
| `lib/features/production/presentation/production_page.dart` | `frontend/lib/features/production/presentation/production_page.dart` |
| `lib/features/profile/presentation/profile_page.dart` | `frontend/lib/features/profile/presentation/profile_page.dart` |
| `lib/features/profile/presentation/profile_settings_pages.dart` | `frontend/lib/features/profile/presentation/profile_settings_pages.dart` |
| `lib/features/reminders/data/reminder_repository.dart` | `backend/lib/features/reminders/repositories/reminder_repository.dart` |
| `lib/features/reminders/domain/reminder.dart` | `backend/lib/features/reminders/domain/reminder.dart` |
| `lib/features/reminders/presentation/reminders_page.dart` | `frontend/lib/features/reminders/presentation/reminders_page.dart` |
| `lib/features/sectors/data/sector_repository.dart` | `backend/lib/features/sectors/repositories/sector_repository.dart` |
| `lib/features/sectors/data/sector_summary_repository.dart` | `backend/lib/features/sectors/repositories/sector_summary_repository.dart` |
| `lib/features/sectors/domain/sector.dart` | `backend/lib/features/sectors/domain/sector.dart` |
| `lib/features/sectors/presentation/quadrant_map_preview.dart` | `frontend/lib/features/sectors/widgets/quadrant_map_preview.dart` |
| `lib/features/sectors/presentation/sector_detail_page.dart` | `frontend/lib/features/sectors/pages/sector_detail_page.dart` |
| `lib/features/sectors/presentation/sector_list_page.dart` | `frontend/lib/features/sectors/pages/sector_list_page.dart` |
| `lib/features/sectors/presentation/sector_summary_card.dart` | `frontend/lib/features/sectors/widgets/sector_summary_card.dart` |
| `lib/features/soil/data/soil_repository.dart` | `backend/lib/features/soil/repositories/soil_repository.dart` |
| `lib/features/soil/domain/soil_measurement.dart` | `backend/lib/features/soil/domain/soil_measurement.dart` |
| `lib/features/soil/presentation/soil_measurement_page.dart` | `frontend/lib/features/soil/presentation/soil_measurement_page.dart` |
| `lib/features/sync_status/presentation/conflict_resolution_page.dart` | `frontend/lib/features/sync_status/presentation/conflict_resolution_page.dart` |
| `lib/features/sync_status/presentation/sync_status_page.dart` | `frontend/lib/features/sync_status/presentation/sync_status_page.dart` |
| `lib/features/weather/data/weather_alert_service.dart` | `backend/lib/features/weather/repositories/weather_alert_service.dart` |
| `lib/features/weather/data/weather_gateway.dart` | `backend/lib/features/weather/repositories/weather_gateway.dart` |
| `lib/features/weather/data/weather_repository.dart` | `backend/lib/features/weather/repositories/weather_repository.dart` |
| `lib/features/weather/domain/weather_snapshot.dart` | `backend/lib/features/weather/domain/weather_snapshot.dart` |
| `lib/features/weather/presentation/weather_summary_card.dart` | `frontend/lib/features/weather/presentation/weather_summary_card.dart` |
| `lib/main.dart` | `frontend/lib/main.dart` |
| `lib/shared/domain/clock.dart` | `backend/lib/shared/domain/clock.dart` |
| `lib/shared/domain/entity_id.dart` | `backend/lib/shared/domain/entity_id.dart` |
| `lib/shared/presentation/components/agricultural_context_selector.dart` | `frontend/lib/shared/presentation/components/agricultural_context_selector.dart` |
| `lib/shared/presentation/components/agro_action_tile.dart` | `frontend/lib/shared/presentation/components/agro_action_tile.dart` |
| `lib/shared/presentation/components/agro_empty_state.dart` | `frontend/lib/shared/presentation/components/agro_empty_state.dart` |
| `lib/shared/presentation/components/agro_metric_card.dart` | `frontend/lib/shared/presentation/components/agro_metric_card.dart` |
| `lib/shared/presentation/components/agro_navigation_card.dart` | `frontend/lib/shared/presentation/components/agro_navigation_card.dart` |
| `lib/shared/presentation/components/agro_page.dart` | `frontend/lib/shared/presentation/components/agro_page.dart` |
| `lib/shared/presentation/components/agro_section_header.dart` | `frontend/lib/shared/presentation/components/agro_section_header.dart` |
| `lib/shared/presentation/components/agro_settings_group.dart` | `frontend/lib/shared/presentation/components/agro_settings_group.dart` |
| `lib/shared/presentation/components/agro_status_banner.dart` | `frontend/lib/shared/presentation/components/agro_status_banner.dart` |
| `lib/shared/presentation/components/bound_agricultural_context_card.dart` | `frontend/lib/shared/presentation/components/bound_agricultural_context_card.dart` |
| `lib/shared/presentation/components/crop_pictogram.dart` | `frontend/lib/shared/presentation/components/crop_pictogram.dart` |
| `lib/shared/presentation/components/foundation_placeholder_page.dart` | `frontend/lib/shared/presentation/components/foundation_placeholder_page.dart` |
| `lib/shared/presentation/semantics/agro_semantics.dart` | `frontend/lib/shared/presentation/semantics/agro_semantics.dart` |
| `backend/lib/features/sectors/controllers/controllers/sector_detail_controller.dart` | `backend/lib/features/sectors/controllers/sector_detail_controller.dart` |
| `backend/lib/features/sectors/controllers/controllers/sector_list_controller.dart` | `backend/lib/features/sectors/controllers/sector_list_controller.dart` |
| `backend/lib/features/sectors/controllers/controllers/sector_ui_mapper.dart` | `backend/lib/features/sectors/services/sector_ui_mapper.dart` |
| `backend/lib/features/sectors/controllers/controllers/sector_ui_state.dart` | `backend/lib/features/sectors/dto/sector_ui_state.dart` |
| `test/app/agro_global_sync_status_test.dart` | `frontend/test/app/agro_global_sync_status_test.dart` |
| `test/app/app_routes_test.dart` | `frontend/test/app/app_routes_test.dart` |
| `test/app/router_test.dart` | `frontend/test/app/router_test.dart` |
| `test/app/theme_test.dart` | `frontend/test/app/theme_test.dart` |
| `test/core/auth/biometric_unlock_gateway_test.dart` | `backend/test/core/auth/biometric_unlock_gateway_test.dart` |
| `test/core/auth/secure_session_store_test.dart` | `backend/test/core/auth/secure_session_store_test.dart` |
| `test/core/database/app_database_test.dart` | `backend/test/core/database/app_database_test.dart` |
| `test/core/database/file_backed_database_test.dart` | `backend/test/core/database/file_backed_database_test.dart` |
| `test/core/database/migrations/functional_core_v10_test.dart` | `backend/test/core/database/migrations/functional_core_v10_test.dart` |
| `test/core/database/owner_isolation_test.dart` | `backend/test/core/database/owner_isolation_test.dart` |
| `test/core/database/sync_outbox_dao_test.dart` | `backend/test/core/database/sync_outbox_dao_test.dart` |
| `test/core/geometry/polygon_geometry_test.dart` | `backend/test/core/geometry/polygon_geometry_test.dart` |
| `test/core/network/runtime_config_test.dart` | `frontend/test/core/network/runtime_config_test.dart` |
| `test/core/notifications/local_notification_scheduler_test.dart` | `backend/test/core/notifications/local_notification_scheduler_test.dart` |
| `test/core/observability/safe_logger_test.dart` | `backend/test/core/observability/safe_logger_test.dart` |
| `test/core/sync/conflict_resolver_test.dart` | `backend/test/core/sync/conflict_resolver_test.dart` |
| `test/core/sync/irrigation_sync_codec_test.dart` | `backend/test/core/sync/irrigation_sync_codec_test.dart` |
| `test/core/sync/labors_production_v2_local_e2e_test.dart` | `backend/test/core/sync/labors_production_v2_local_e2e_test.dart` |
| `test/core/sync/labor_sync_codec_test.dart` | `backend/test/core/sync/labor_sync_codec_test.dart` |
| `test/core/sync/parcel_sync_v2_local_e2e_test.dart` | `backend/test/core/sync/parcel_sync_v2_local_e2e_test.dart` |
| `test/core/sync/seasons_crops_sync_codec_test.dart` | `backend/test/core/sync/seasons_crops_sync_codec_test.dart` |
| `test/core/sync/seasons_crops_v2_local_e2e_test.dart` | `backend/test/core/sync/seasons_crops_v2_local_e2e_test.dart` |
| `test/core/sync/supabase_sync_gateway_test.dart` | `backend/test/core/sync/supabase_sync_gateway_test.dart` |
| `test/core/sync/sync_contract_test.dart` | `backend/test/core/sync/sync_contract_test.dart` |
| `test/core/sync/sync_retry_policy_test.dart` | `backend/test/core/sync/sync_retry_policy_test.dart` |
| `test/core/sync/sync_trigger_coordinator_test.dart` | `backend/test/core/sync/sync_trigger_coordinator_test.dart` |
| `test/core/sync/territory_sync_codec_test.dart` | `backend/test/core/sync/territory_sync_codec_test.dart` |
| `test/core/sync/territory_sync_v2_local_e2e_test.dart` | `backend/test/core/sync/territory_sync_v2_local_e2e_test.dart` |
| `test/features/agro_ai/agro_ai_repository_test.dart` | `backend/test/features/agro_ai/agro_ai_repository_test.dart` |
| `test/features/apiary/apiary_repository_test.dart` | `backend/test/features/apiary/apiary_repository_test.dart` |
| `test/features/auth/session_controller_test.dart` | `backend/test/features/auth/session_controller_test.dart` |
| `test/features/context/agricultural_context_controller_test.dart` | `backend/test/features/context/agricultural_context_controller_test.dart` |
| `test/features/context/bound_agricultural_context_test.dart` | `backend/test/features/context/bound_agricultural_context_test.dart` |
| `test/features/crops/agricultural_season_test.dart` | `backend/test/features/crops/agricultural_season_test.dart` |
| `test/features/crops/crop_catalog_page_test.dart` | `frontend/test/features/crops/crop_catalog_page_test.dart` |
| `test/features/crops/crop_repository_test.dart` | `backend/test/features/crops/crop_repository_test.dart` |
| `test/features/crops/crop_rotation_test.dart` | `backend/test/features/crops/crop_rotation_test.dart` |
| `test/features/crops/crop_seed_loader_test.dart` | `backend/test/features/crops/crop_seed_loader_test.dart` |
| `test/features/export/xlsx_contract_test.dart` | `backend/test/features/export/xlsx_contract_test.dart` |
| `test/features/history/history_event_test.dart` | `backend/test/features/history/history_event_test.dart` |
| `test/features/history/history_page_test.dart` | `frontend/test/features/history/history_page_test.dart` |
| `test/features/history/history_repository_test.dart` | `backend/test/features/history/history_repository_test.dart` |
| `test/features/home/home_page_test.dart` | `frontend/test/features/home/home_page_test.dart` |
| `test/features/irrigation/basic_record_test.dart` | `backend/test/features/irrigation/basic_record_test.dart` |
| `test/features/irrigation/irrigation_calculator_test.dart` | `backend/test/features/irrigation/irrigation_calculator_test.dart` |
| `test/features/irrigation/irrigation_estimate_repository_test.dart` | `backend/test/features/irrigation/irrigation_estimate_repository_test.dart` |
| `test/features/irrigation/irrigation_explanation_test.dart` | `backend/test/features/irrigation/irrigation_explanation_test.dart` |
| `test/features/irrigation/irrigation_record_page_test.dart` | `frontend/test/features/irrigation/irrigation_record_page_test.dart` |
| `test/features/irrigation/irrigation_rule_approval_test.dart` | `backend/test/features/irrigation/irrigation_rule_approval_test.dart` |
| `test/features/irrigation/irrigation_snapshot_persistence_test.dart` | `backend/test/features/irrigation/irrigation_snapshot_persistence_test.dart` |
| `test/features/irrigation/sector_irrigation_config_test.dart` | `backend/test/features/irrigation/sector_irrigation_config_test.dart` |
| `test/features/labors/agrochemical_details_test.dart` | `backend/test/features/labors/agrochemical_details_test.dart` |
| `test/features/labors/cultural_labor_details_test.dart` | `backend/test/features/labors/cultural_labor_details_test.dart` |
| `test/features/labors/labor_details_test.dart` | `backend/test/features/labors/labor_details_test.dart` |
| `test/features/labors/labor_form_page_test.dart` | `frontend/test/features/labors/labor_form_page_test.dart` |
| `test/features/labors/labor_repository_test.dart` | `backend/test/features/labors/labor_repository_test.dart` |
| `test/features/map/location_gateway_test.dart` | `backend/test/features/map/location_gateway_test.dart` |
| `test/features/map/territory_map_page_test.dart` | `frontend/test/features/map/territory_map_page_test.dart` |
| `test/features/map/territory_persistence_flow_test.dart` | `backend/test/features/map/territory_persistence_flow_test.dart` |
| `test/features/more/more_page_test.dart` | `frontend/test/features/more/more_page_test.dart` |
| `test/features/parcels/parcel_repository_test.dart` | `backend/test/features/parcels/parcel_repository_test.dart` |
| `test/features/photos/photo_repository_test.dart` | `backend/test/features/photos/photo_repository_test.dart` |
| `test/features/production/production_repository_test.dart` | `backend/test/features/production/production_repository_test.dart` |
| `test/features/profile/profile_page_test.dart` | `frontend/test/features/profile/profile_page_test.dart` |
| `test/features/reminders/reminder_repository_test.dart` | `backend/test/features/reminders/reminder_repository_test.dart` |
| `test/features/sectors/sector_list_page_test.dart` | `frontend/test/features/sectors/sector_list_page_test.dart` |
| `test/features/sectors/sector_repository_test.dart` | `backend/test/features/sectors/sector_repository_test.dart` |
| `test/features/sectors/sector_summary_repository_test.dart` | `backend/test/features/sectors/sector_summary_repository_test.dart` |
| `test/features/sectors/sector_ui_state_test.dart` | `backend/test/features/sectors/sector_ui_state_test.dart` |
| `test/features/soil/soil_repository_test.dart` | `backend/test/features/soil/soil_repository_test.dart` |
| `test/features/sync_status/sync_status_page_test.dart` | `frontend/test/features/sync_status/sync_status_page_test.dart` |
| `test/features/weather/weather_gateway_contract_test.dart` | `backend/test/features/weather/weather_gateway_contract_test.dart` |
| `test/features/weather/weather_summary_card_test.dart` | `frontend/test/features/weather/weather_summary_card_test.dart` |
| `test/fixtures/database/functional_core_v9.dart` | `backend/test/fixtures/database/functional_core_v9.dart` |
| `test/fixtures/export/README.md` | `backend/test/fixtures/export/README.md` |
| `test/fixtures/irrigation/README.md` | `backend/test/fixtures/irrigation/README.md` |
| `test/generated/migrations/schema.dart` | `backend/test/generated/migrations/schema.dart` |
| `test/generated/migrations/schema_v10.dart` | `backend/test/generated/migrations/schema_v10.dart` |
| `test/generated/migrations/schema_v9.dart` | `backend/test/generated/migrations/schema_v9.dart` |
| `test/golden/us1/crop_catalog.png` | `frontend/test/golden/us1/crop_catalog.png` |
| `test/golden/us1/crop_catalog_golden_test.dart` | `frontend/test/golden/us1/crop_catalog_golden_test.dart` |
| `test/golden/us1/failures/crop_catalog_isolatedDiff.png` | `frontend/test/golden/us1/failures/crop_catalog_isolatedDiff.png` |
| `test/golden/us1/failures/crop_catalog_maskedDiff.png` | `frontend/test/golden/us1/failures/crop_catalog_maskedDiff.png` |
| `test/golden/us1/failures/crop_catalog_masterImage.png` | `frontend/test/golden/us1/failures/crop_catalog_masterImage.png` |
| `test/golden/us1/failures/crop_catalog_testImage.png` | `frontend/test/golden/us1/failures/crop_catalog_testImage.png` |
| `test/golden/us2/failures/labor_form_isolatedDiff.png` | `frontend/test/golden/us2/failures/labor_form_isolatedDiff.png` |
| `test/golden/us2/failures/labor_form_maskedDiff.png` | `frontend/test/golden/us2/failures/labor_form_maskedDiff.png` |
| `test/golden/us2/failures/labor_form_masterImage.png` | `frontend/test/golden/us2/failures/labor_form_masterImage.png` |
| `test/golden/us2/failures/labor_form_testImage.png` | `frontend/test/golden/us2/failures/labor_form_testImage.png` |
| `test/golden/us2/labor_form.png` | `frontend/test/golden/us2/labor_form.png` |
| `test/golden/us2/labor_form_golden_test.dart` | `frontend/test/golden/us2/labor_form_golden_test.dart` |
| `test/golden/us3/failures/sync_status_isolatedDiff.png` | `frontend/test/golden/us3/failures/sync_status_isolatedDiff.png` |
| `test/golden/us3/failures/sync_status_maskedDiff.png` | `frontend/test/golden/us3/failures/sync_status_maskedDiff.png` |
| `test/golden/us3/failures/sync_status_masterImage.png` | `frontend/test/golden/us3/failures/sync_status_masterImage.png` |
| `test/golden/us3/failures/sync_status_testImage.png` | `frontend/test/golden/us3/failures/sync_status_testImage.png` |
| `test/golden/us3/sync_status.png` | `frontend/test/golden/us3/sync_status.png` |
| `test/golden/us3/sync_status_golden_test.dart` | `frontend/test/golden/us3/sync_status_golden_test.dart` |
| `test/golden/us4/failures/irrigation_unavailable_isolatedDiff.png` | `frontend/test/golden/us4/failures/irrigation_unavailable_isolatedDiff.png` |
| `test/golden/us4/failures/irrigation_unavailable_maskedDiff.png` | `frontend/test/golden/us4/failures/irrigation_unavailable_maskedDiff.png` |
| `test/golden/us4/failures/irrigation_unavailable_masterImage.png` | `frontend/test/golden/us4/failures/irrigation_unavailable_masterImage.png` |
| `test/golden/us4/failures/irrigation_unavailable_testImage.png` | `frontend/test/golden/us4/failures/irrigation_unavailable_testImage.png` |
| `test/golden/us4/irrigation_unavailable.png` | `frontend/test/golden/us4/irrigation_unavailable.png` |
| `test/golden/us4/irrigation_unavailable_golden_test.dart` | `frontend/test/golden/us4/irrigation_unavailable_golden_test.dart` |
| `test/golden/us5/failures/production_isolatedDiff.png` | `frontend/test/golden/us5/failures/production_isolatedDiff.png` |
| `test/golden/us5/failures/production_maskedDiff.png` | `frontend/test/golden/us5/failures/production_maskedDiff.png` |
| `test/golden/us5/failures/production_masterImage.png` | `frontend/test/golden/us5/failures/production_masterImage.png` |
| `test/golden/us5/failures/production_testImage.png` | `frontend/test/golden/us5/failures/production_testImage.png` |
| `test/golden/us5/production.png` | `frontend/test/golden/us5/production.png` |
| `test/golden/us5/production_golden_test.dart` | `frontend/test/golden/us5/production_golden_test.dart` |
| `test/golden/us6/failures/photo_attachment_isolatedDiff.png` | `frontend/test/golden/us6/failures/photo_attachment_isolatedDiff.png` |
| `test/golden/us6/failures/photo_attachment_maskedDiff.png` | `frontend/test/golden/us6/failures/photo_attachment_maskedDiff.png` |
| `test/golden/us6/failures/photo_attachment_masterImage.png` | `frontend/test/golden/us6/failures/photo_attachment_masterImage.png` |
| `test/golden/us6/failures/photo_attachment_testImage.png` | `frontend/test/golden/us6/failures/photo_attachment_testImage.png` |
| `test/golden/us6/photo_attachment.png` | `frontend/test/golden/us6/photo_attachment.png` |
| `test/golden/us6/photo_attachment_golden_test.dart` | `frontend/test/golden/us6/photo_attachment_golden_test.dart` |
| `test/golden/us7/apiary.png` | `frontend/test/golden/us7/apiary.png` |
| `test/golden/us7/apiary_golden_test.dart` | `frontend/test/golden/us7/apiary_golden_test.dart` |
| `test/golden/us7/failures/apiary_isolatedDiff.png` | `frontend/test/golden/us7/failures/apiary_isolatedDiff.png` |
| `test/golden/us7/failures/apiary_maskedDiff.png` | `frontend/test/golden/us7/failures/apiary_maskedDiff.png` |
| `test/golden/us7/failures/apiary_masterImage.png` | `frontend/test/golden/us7/failures/apiary_masterImage.png` |
| `test/golden/us7/failures/apiary_testImage.png` | `frontend/test/golden/us7/failures/apiary_testImage.png` |
| `test/golden/us8/export.png` | `frontend/test/golden/us8/export.png` |
| `test/golden/us8/export_golden_test.dart` | `frontend/test/golden/us8/export_golden_test.dart` |
| `test/golden/us8/failures/export_isolatedDiff.png` | `frontend/test/golden/us8/failures/export_isolatedDiff.png` |
| `test/golden/us8/failures/export_maskedDiff.png` | `frontend/test/golden/us8/failures/export_maskedDiff.png` |
| `test/golden/us8/failures/export_masterImage.png` | `frontend/test/golden/us8/failures/export_masterImage.png` |
| `test/golden/us8/failures/export_testImage.png` | `frontend/test/golden/us8/failures/export_testImage.png` |
| `test/helpers/file_backed_database.dart` | `backend/test/helpers/file_backed_database.dart` |
| `test/helpers/in_memory_database.dart` | `backend/test/helpers/in_memory_database.dart` |
| `test/helpers/signed_in_widget_scope.dart` | `backend/test/helpers/signed_in_widget_scope.dart` |
| `test/helpers/territory_fixture.dart` | `backend/test/helpers/territory_fixture.dart` |
| `test/integration/agro_ai_privacy_scenario.dart` | `backend/test/integration/agro_ai_privacy_scenario.dart` |
| `test/integration/compatibility_001_scenario.dart` | `backend/test/integration/compatibility_001_scenario.dart` |
| `test/integration/functional_core_offline_restart_scenario.dart` | `backend/test/integration/functional_core_offline_restart_scenario.dart` |
| `test/integration/multi_context_scenario.dart` | `backend/test/integration/multi_context_scenario.dart` |
| `test/integration/reminder_restart_scenario.dart` | `backend/test/integration/reminder_restart_scenario.dart` |
| `test/integration/session_persistence_scenario.dart` | `backend/test/integration/session_persistence_scenario.dart` |
| `test/integration/session_sync_isolation_scenario.dart` | `backend/test/integration/session_sync_isolation_scenario.dart` |
| `test/integration/sync_conflict_tombstone_scenario.dart` | `backend/test/integration/sync_conflict_tombstone_scenario.dart` |
| `test/integration/weather_alert_scenario.dart` | `backend/test/integration/weather_alert_scenario.dart` |
| `test/performance/functional_core_performance_test.dart` | `backend/test/performance/functional_core_performance_test.dart` |
| `test/performance/xlsx_performance_test.dart` | `backend/test/performance/xlsx_performance_test.dart` |
| `test/shared/agricultural_context_selector_test.dart` | `frontend/test/shared/agricultural_context_selector_test.dart` |
| `test/shared/component_semantics_test.dart` | `frontend/test/shared/component_semantics_test.dart` |
| `test/shared/design_policy_test.dart` | `frontend/test/shared/design_policy_test.dart` |
| `test/shared/screen_inventory_test.dart` | `frontend/test/shared/screen_inventory_test.dart` |
| `test/widget_test.dart` | `frontend/test/widget_test.dart` |
| `integration_test/001_compatibility_regression_test.dart` | `frontend/integration_test/001_compatibility_regression_test.dart` |
| `integration_test/agricultural_context_selector_android_test.dart` | `frontend/integration_test/agricultural_context_selector_android_test.dart` |
| `integration_test/agro_ai_privacy_flow_test.dart` | `frontend/integration_test/agro_ai_privacy_flow_test.dart` |
| `integration_test/android_map_device_test.dart` | `frontend/integration_test/android_map_device_test.dart` |
| `integration_test/android_platform_flow_test.dart` | `frontend/integration_test/android_platform_flow_test.dart` |
| `integration_test/apiary_flow_test.dart` | `frontend/integration_test/apiary_flow_test.dart` |
| `integration_test/critical_offline_flows_test.dart` | `frontend/integration_test/critical_offline_flows_test.dart` |
| `integration_test/foundation_smoke_test.dart` | `frontend/integration_test/foundation_smoke_test.dart` |
| `integration_test/functional_core_offline_restart_test.dart` | `frontend/integration_test/functional_core_offline_restart_test.dart` |
| `integration_test/history_production_flow_test.dart` | `frontend/integration_test/history_production_flow_test.dart` |
| `integration_test/irrigation_calculation_flow_test.dart` | `frontend/integration_test/irrigation_calculation_flow_test.dart` |
| `integration_test/labors_production_flow_test.dart` | `frontend/integration_test/labors_production_flow_test.dart` |
| `integration_test/multi_context_e2e_test.dart` | `frontend/integration_test/multi_context_e2e_test.dart` |
| `integration_test/parcel_sync_v2_e2e_test.dart` | `frontend/integration_test/parcel_sync_v2_e2e_test.dart` |
| `integration_test/photos_reminders_flow_test.dart` | `frontend/integration_test/photos_reminders_flow_test.dart` |
| `integration_test/reminder_restart_flow_test.dart` | `frontend/integration_test/reminder_restart_flow_test.dart` |
| `integration_test/resilience_upgrade_test.dart` | `frontend/integration_test/resilience_upgrade_test.dart` |
| `integration_test/seasons_crops_flow_test.dart` | `frontend/integration_test/seasons_crops_flow_test.dart` |
| `integration_test/session_persistence_flow_test.dart` | `frontend/integration_test/session_persistence_flow_test.dart` |
| `integration_test/session_sync_isolation_e2e_test.dart` | `frontend/integration_test/session_sync_isolation_e2e_test.dart` |
| `integration_test/synchronization_test.dart` | `frontend/integration_test/synchronization_test.dart` |
| `integration_test/sync_conflict_tombstone_e2e_test.dart` | `frontend/integration_test/sync_conflict_tombstone_e2e_test.dart` |
| `integration_test/territory_flow_test.dart` | `frontend/integration_test/territory_flow_test.dart` |
| `integration_test/weather_ai_export_flow_test.dart` | `frontend/integration_test/weather_ai_export_flow_test.dart` |
| `integration_test/weather_alert_flow_test.dart` | `frontend/integration_test/weather_alert_flow_test.dart` |
| `assets/data/crop_catalog_v1.json` | `backend/assets/data/crop_catalog_v1.json` |
| `assets/fonts/inter/.gitkeep` | `frontend/assets/fonts/inter/.gitkeep` |
| `assets/fonts/inter/Inter-Variable.ttf` | `frontend/assets/fonts/inter/Inter-Variable.ttf` |
| `assets/icons/berries.svg` | `frontend/assets/icons/berries.svg` |
| `assets/icons/corn.svg` | `frontend/assets/icons/corn.svg` |
| `assets/icons/crops/apiary.svg` | `frontend/assets/icons/crops/apiary.svg` |
| `assets/icons/crops/custom-crop.svg` | `frontend/assets/icons/crops/custom-crop.svg` |
| `assets/icons/crops/physalis.svg` | `frontend/assets/icons/crops/physalis.svg` |
| `assets/icons/melon.svg` | `frontend/assets/icons/melon.svg` |
| `assets/icons/raspberry.svg` | `frontend/assets/icons/raspberry.svg` |
| `assets/icons/root.svg` | `frontend/assets/icons/root.svg` |
| `assets/icons/strawberry.svg` | `frontend/assets/icons/strawberry.svg` |
| `assets/icons/watermelon.svg` | `frontend/assets/icons/watermelon.svg` |
| `supabase/supabase/.branches/_current_branch` | `backend/supabase/.branches/_current_branch` |
| `supabase/supabase/.temp/cli-latest` | `backend/supabase/.temp/cli-latest` |
| `supabase/supabase/.temp/linked-project.json` | `backend/supabase/.temp/linked-project.json` |
| `supabase/supabase/.temp/start-secrets/supabase_edge_runtime_agrocampo-local/env/docker.env` | `backend/supabase/.temp/start-secrets/supabase_edge_runtime_agrocampo-local/env/docker.env` |
| `supabase/supabase/config.toml` | `backend/supabase/config.toml` |
| `supabase/supabase/functions/agro-ai/index.ts` | `backend/supabase/functions/agro-ai/index.ts` |
| `supabase/supabase/functions/agro-ai/prompt.ts` | `backend/supabase/functions/agro-ai/prompt.ts` |
| `supabase/supabase/functions/agro-ai/tests/prompt_eval_test.ts` | `backend/supabase/functions/agro-ai/tests/prompt_eval_test.ts` |
| `supabase/supabase/functions/notification-dispatch/index.ts` | `backend/supabase/functions/notification-dispatch/index.ts` |
| `supabase/supabase/functions/weather-proxy/index.ts` | `backend/supabase/functions/weather-proxy/index.ts` |
| `supabase/supabase/functions/weather-proxy/tests/weather_contract_test.ts` | `backend/supabase/functions/weather-proxy/tests/weather_contract_test.ts` |
| `supabase/supabase/migrations/0001_auth_profile_rls.sql` | `backend/supabase/migrations/0001_auth_profile_rls.sql` |
| `supabase/supabase/migrations/0002_parcel_sync_slice.sql` | `backend/supabase/migrations/0002_parcel_sync_slice.sql` |
| `supabase/supabase/migrations/0003_sync_protocol.sql` | `backend/supabase/migrations/0003_sync_protocol.sql` |
| `supabase/supabase/migrations/0004_territory.sql` | `backend/supabase/migrations/0004_territory.sql` |
| `supabase/supabase/migrations/0005_labors_soil_irrigation.sql` | `backend/supabase/migrations/0005_labors_soil_irrigation.sql` |
| `supabase/supabase/migrations/0006_irrigation_rules.sql` | `backend/supabase/migrations/0006_irrigation_rules.sql` |
| `supabase/supabase/migrations/0007_production_history.sql` | `backend/supabase/migrations/0007_production_history.sql` |
| `supabase/supabase/migrations/0008_photos_storage.sql` | `backend/supabase/migrations/0008_photos_storage.sql` |
| `supabase/supabase/migrations/0009_reminders.sql` | `backend/supabase/migrations/0009_reminders.sql` |
| `supabase/supabase/migrations/0010_device_installations.sql` | `backend/supabase/migrations/0010_device_installations.sql` |
| `supabase/supabase/migrations/0011_apiary.sql` | `backend/supabase/migrations/0011_apiary.sql` |
| `supabase/supabase/migrations/0012_functional_core_schema.sql` | `backend/supabase/migrations/0012_functional_core_schema.sql` |
| `supabase/supabase/migrations/0013_sync_protocol_v2.sql` | `backend/supabase/migrations/0013_sync_protocol_v2.sql` |
| `supabase/supabase/migrations/0014_sync_territory_handlers.sql` | `backend/supabase/migrations/0014_sync_territory_handlers.sql` |
| `supabase/supabase/migrations/0015_sync_seasons_crops_handlers.sql` | `backend/supabase/migrations/0015_sync_seasons_crops_handlers.sql` |
| `supabase/supabase/migrations/0016_sync_labor_handlers.sql` | `backend/supabase/migrations/0016_sync_labor_handlers.sql` |
| `supabase/supabase/migrations/0017_sync_irrigation_handlers.sql` | `backend/supabase/migrations/0017_sync_irrigation_handlers.sql` |
| `supabase/supabase/migrations/0018_sync_reminder_handler.sql` | `backend/supabase/migrations/0018_sync_reminder_handler.sql` |
| `supabase/supabase/migrations/0019_irrigation_rule_release_gate.sql` | `backend/supabase/migrations/0019_irrigation_rule_release_gate.sql` |
| `supabase/supabase/seed.sql` | `backend/supabase/seed.sql` |
| `supabase/supabase/tests/database/apiary_rls_test.sql` | `backend/supabase/tests/database/apiary_rls_test.sql` |
| `supabase/supabase/tests/database/auth_rls_test.sql` | `backend/supabase/tests/database/auth_rls_test.sql` |
| `supabase/supabase/tests/database/device_installations_rls_test.sql` | `backend/supabase/tests/database/device_installations_rls_test.sql` |
| `supabase/supabase/tests/database/functional_core_schema_test.sql` | `backend/supabase/tests/database/functional_core_schema_test.sql` |
| `supabase/supabase/tests/database/irrigation_rule_release_gate_test.sql` | `backend/supabase/tests/database/irrigation_rule_release_gate_test.sql` |
| `supabase/supabase/tests/database/irrigation_sync_v2_test.sql` | `backend/supabase/tests/database/irrigation_sync_v2_test.sql` |
| `supabase/supabase/tests/database/labor_sync_v2_test.sql` | `backend/supabase/tests/database/labor_sync_v2_test.sql` |
| `supabase/supabase/tests/database/photo_storage_rls_test.sql` | `backend/supabase/tests/database/photo_storage_rls_test.sql` |
| `supabase/supabase/tests/database/reminder_sync_v2_test.sql` | `backend/supabase/tests/database/reminder_sync_v2_test.sql` |
| `supabase/supabase/tests/database/rls_coverage_test.sql` | `backend/supabase/tests/database/rls_coverage_test.sql` |
| `supabase/supabase/tests/database/seasons_crops_sync_v2_test.sql` | `backend/supabase/tests/database/seasons_crops_sync_v2_test.sql` |
| `supabase/supabase/tests/database/sync_protocol_test.sql` | `backend/supabase/tests/database/sync_protocol_test.sql` |
| `supabase/supabase/tests/database/sync_protocol_v2_test.sql` | `backend/supabase/tests/database/sync_protocol_v2_test.sql` |
| `supabase/supabase/tests/database/territory_rls_test.sql` | `backend/supabase/tests/database/territory_rls_test.sql` |
| `supabase/supabase/tests/database/territory_sync_v2_test.sql` | `backend/supabase/tests/database/territory_sync_v2_test.sql` |
| `drift_schemas/drift_schemas/.gitkeep` | `backend/drift_schemas/.gitkeep` |
| `drift_schemas/drift_schemas/drift_schema_v10.json` | `backend/drift_schemas/drift_schema_v10.json` |
| `drift_schemas/drift_schemas/drift_schema_v9.json` | `backend/drift_schemas/drift_schema_v9.json` |
| `pubspec.yaml` | `frontend/pubspec.yaml` |
| `pubspec.lock` | `frontend/pubspec.lock` |
| `analysis_options.yaml` | `frontend/analysis_options.yaml` |
| `.metadata` | `frontend/.metadata` |
| `agrocampo.iml` | `frontend/agrocampo.iml` |
| `build.yaml` | `backend/build.yaml` |
| `android/.gitignore` | `frontend/android/.gitignore` |
| `android/app/build.gradle.kts` | `frontend/android/app/build.gradle.kts` |
| `android/app/src/debug/AndroidManifest.xml` | `frontend/android/app/src/debug/AndroidManifest.xml` |
| `android/app/src/main/AndroidManifest.xml` | `frontend/android/app/src/main/AndroidManifest.xml` |
| `android/app/src/main/kotlin/cl/agrocampo/app/MainActivity.kt` | `frontend/android/app/src/main/kotlin/cl/agrocampo/app/MainActivity.kt` |
| `android/app/src/main/res/drawable-v21/launch_background.xml` | `frontend/android/app/src/main/res/drawable-v21/launch_background.xml` |
| `android/app/src/main/res/drawable/launch_background.xml` | `frontend/android/app/src/main/res/drawable/launch_background.xml` |
| `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` | `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png` |
| `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png` |
| `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` | `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` |
| `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` | `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` |
| `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` |
| `android/app/src/main/res/values-night/styles.xml` | `frontend/android/app/src/main/res/values-night/styles.xml` |
| `android/app/src/main/res/values/styles.xml` | `frontend/android/app/src/main/res/values/styles.xml` |
| `android/app/src/profile/AndroidManifest.xml` | `frontend/android/app/src/profile/AndroidManifest.xml` |
| `android/build.gradle.kts` | `frontend/android/build.gradle.kts` |
| `android/gradle.properties` | `frontend/android/gradle.properties` |
| `android/gradle/wrapper/gradle-wrapper.properties` | `frontend/android/gradle/wrapper/gradle-wrapper.properties` |
| `android/settings.gradle.kts` | `frontend/android/settings.gradle.kts` |

## Archivos nuevos de código y pruebas

- `frontend/lib/app/routing/app_routes.dart`
- `backend/lib/agrocampo_backend.dart`
- `backend/lib/core/config/app_lifecycle_controller.dart`
- `backend/lib/core/config/backend_bootstrap.dart`
- `backend/lib/features/agro_ai/agro_ai_api.dart`
- `backend/lib/features/agro_ai/controllers/agro_ai_controller.dart`
- `backend/lib/features/apiary/apiary_api.dart`
- `backend/lib/features/apiary/controllers/apiary_inspection_controller.dart`
- `backend/lib/features/context/controllers/context_options_controller.dart`
- `backend/lib/features/context/dto/context_options.dart`
- `backend/lib/features/crops/controllers/crops_controller.dart`
- `backend/lib/features/crops/crops_api.dart`
- `backend/lib/features/export/controllers/export_controller.dart`
- `backend/lib/features/export/export_api.dart`
- `backend/lib/features/history/controllers/history_controller.dart`
- `backend/lib/features/history/history_api.dart`
- `backend/lib/features/irrigation/controllers/irrigation_form_controller.dart`
- `backend/lib/features/irrigation/dto/irrigation_form_input.dart`
- `backend/lib/features/irrigation/irrigation_api.dart`
- `backend/lib/features/labors/controllers/labor_form_controller.dart`
- `backend/lib/features/labors/dto/labor_form_input.dart`
- `backend/lib/features/labors/labors_api.dart`
- `backend/lib/features/map/controllers/territory_map_controller.dart`
- `backend/lib/features/map/map_api.dart`
- `backend/lib/features/parcels/controllers/parcel_controller.dart`
- `backend/lib/features/parcels/dto/parcel_view.dart`
- `backend/lib/features/photos/controllers/photo_attachment_controller.dart`
- `backend/lib/features/photos/photos_api.dart`
- `backend/lib/features/production/controllers/production_controller.dart`
- `backend/lib/features/production/dto/production_form_input.dart`
- `backend/lib/features/production/production_api.dart`
- `backend/lib/features/profile/controllers/profile_controller.dart`
- `backend/lib/features/profile/dto/profile_ui_state.dart`
- `backend/lib/features/profile/profile_api.dart`
- `backend/lib/features/reminders/controllers/reminders_controller.dart`
- `backend/lib/features/reminders/reminders_api.dart`
- `backend/lib/features/soil/controllers/soil_measurement_controller.dart`
- `backend/lib/features/soil/soil_api.dart`
- `backend/lib/features/sync_status/controllers/sync_status_controller.dart`
- `backend/lib/features/sync_status/dto/sync_status_ui_state.dart`
- `backend/lib/features/sync_status/sync_status_api.dart`
- `backend/lib/features/weather/controllers/weather_controller.dart`
- `backend/lib/features/weather/domain/weather_load_result.dart`
- `backend/lib/features/weather/weather_api.dart`
- `frontend/test/architecture/frontend_backend_boundary_test.dart`
- `backend/test/contracts/feature_api_test.dart`
- `backend/test/contracts/parcel_context_contract_test.dart`

## Configuración y documentación nuevas

- `backend/pubspec.yaml`
- `backend/pubspec.lock`
- `backend/analysis_options.yaml`
- `backend/README.md`
- `frontend/README.md`
- `docs/architecture/frontend-backend-boundary.md`
- `docs/architecture/migration-report.md`
- `docs/architecture/migration-manifest.json`
- `docs/architecture/migration-files.md`
- `docs/architecture/verify-migration.cjs`
- `docs/architecture/write-inventory.cjs`

## Retirada de ubicaciones obsoletas

No se borraron implementaciones: los originales se movieron. Se eliminaron 188 directorios comprobados vacíos, incluyendo `lib/`, `test/`, `integration_test/`, `assets/`, `drift_schemas/`, `supabase/` y la anidación `controllers/controllers/`. El detalle está en [removed-empty-directories.json](./validation/removed-empty-directories.json). Las caches de la raíz se conservaron en `frontend/.migration-cache/` (ignoradas, sin uso productivo). Los scripts temporales de ejecución de esta migración se retiraron al concluir.
