import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const input = 'draft';
  final command = CommandId('cmd-1');

  test('command ids and field errors compare by value', () {
    expect(CommandId('cmd-1'), command);
    expect(
      const FieldError(fieldId: 'flow', code: 'invalid', message: 'Inválido'),
      const FieldError(fieldId: 'flow', code: 'invalid', message: 'Inválido'),
    );
  });

  test('saved local preserves value and never claims remote backup', () {
    final outcome = SavedLocal<String>(commandId: command, value: input);
    expect(outcome.value, input);
    expect(outcome.backupState, BackupState.pending);
    expect(outcome.isSuccess, isTrue);
  });

  test('failures preserve input and typed error data', () {
    final validation = ValidationFailed<String>(
      commandId: command,
      fieldErrors: const [
        FieldError(fieldId: 'name', code: 'required', message: 'Requerido'),
      ],
      preservedInput: input,
    );
    final domain = DomainRejected<String>(
      commandId: command,
      failure: const DomainFailure(
        operation: 'irrigationRecord',
        category: 'apiary',
        code: 'operation_not_valid_for_apiary',
        message: 'No corresponde',
      ),
      preservedInput: input,
    );
    final storage = StorageFailed<String>(
      commandId: command,
      failure: const StorageFailure(
        code: 'disk_unavailable',
        message: 'No se pudo guardar',
      ),
      preservedInput: input,
    );
    expect(validation.preservedInput, input);
    expect(domain.failure.category, 'apiary');
    expect(storage.failure.retryable, isTrue);
    expect(validation.isSuccess, isFalse);
  });
}
