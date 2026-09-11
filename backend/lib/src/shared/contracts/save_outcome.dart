/// Stable identifier for one user confirmation.
/// It is also the idempotency key used by repositories and the outbox.
final class CommandId {
  CommandId(String value) : value = value.trim() {
    if (this.value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be empty');
    }
  }

  final String value;

  @override
  bool operator ==(Object other) => other is CommandId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class FieldError {
  const FieldError({
    required this.fieldId,
    required this.code,
    required this.message,
  });

  final String fieldId;
  final String code;
  final String message;

  @override
  bool operator ==(Object other) =>
      other is FieldError &&
      other.fieldId == fieldId &&
      other.code == code &&
      other.message == message;

  @override
  int get hashCode => Object.hash(fieldId, code, message);
}

final class DomainFailure implements Exception {
  const DomainFailure({
    required this.operation,
    required this.category,
    required this.code,
    required this.message,
    this.fieldErrors = const <FieldError>[],
  });

  final String operation;
  final String category;
  final String code;
  final String message;
  final List<FieldError> fieldErrors;

  @override
  String toString() => 'DomainFailure($code)';
}

final class StorageFailure implements Exception {
  const StorageFailure({
    required this.code,
    required this.message,
    this.retryable = true,
  });

  final String code;
  final String message;
  final bool retryable;

  @override
  String toString() => 'StorageFailure($code)';
}

enum BackupState { pending, syncing, backedUp, error, conflict }

sealed class SaveOutcome<T> {
  const SaveOutcome({required this.commandId});

  final CommandId commandId;

  bool get isSuccess => this is SavedLocal<T>;
}

final class SavedLocal<T> extends SaveOutcome<T> {
  const SavedLocal({
    required super.commandId,
    required this.value,
    this.backupState = BackupState.pending,
  });

  final T value;
  final BackupState backupState;
}

final class ValidationFailed<T> extends SaveOutcome<T> {
  const ValidationFailed({
    required super.commandId,
    required this.fieldErrors,
    required this.preservedInput,
  });

  final List<FieldError> fieldErrors;
  final T preservedInput;
}

final class DomainRejected<T> extends SaveOutcome<T> {
  const DomainRejected({
    required super.commandId,
    required this.failure,
    required this.preservedInput,
  });

  final DomainFailure failure;
  final T preservedInput;
}

final class StaleVersion<T> extends SaveOutcome<T> {
  const StaleVersion({
    required super.commandId,
    required this.currentVersion,
    required this.preservedInput,
  });

  final int currentVersion;
  final T preservedInput;
}

final class StorageFailed<T> extends SaveOutcome<T> {
  const StorageFailed({
    required super.commandId,
    required this.failure,
    required this.preservedInput,
  });

  final StorageFailure failure;
  final T preservedInput;
}
