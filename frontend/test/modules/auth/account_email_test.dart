import 'package:agrocampo/src/modules/auth/presentation/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a short user name maps to the account email', () {
    expect(accountEmail('Mario'), 'mario@agrocampo.app');
    expect(accountEmail('  mario '), 'mario@agrocampo.app');
  });

  test('a full email is used as typed, normalized', () {
    expect(accountEmail('Mario@Ejemplo.cl'), 'mario@ejemplo.cl');
  });
}
