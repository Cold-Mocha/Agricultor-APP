import 'functional_core_offline_restart_scenario.dart' as baseline;

/// Reuses the file-backed restart harness. Domain-specific restart coverage
/// lives beside each specialization; this scenario guards the shared
/// offline/outbox invariant without duplicating the functional-core fixture.
void main() => baseline.main();
