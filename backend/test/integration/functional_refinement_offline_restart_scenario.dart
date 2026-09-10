import 'functional_core_offline_restart_scenario.dart' as baseline;

/// Reuses the proven file-backed restart harness for 003. Domain-specific
/// restart coverage lives beside each specialization; this scenario guards
/// the shared offline/outbox invariant without duplicating the 002 fixture.
void main() => baseline.main();
