import '../../../backend/test/platform/database/owner_isolation_test.dart'
    as isolation;
import '../modules/auth/session_controller_test.dart' as session;

void main() {
  isolation.main();
  session.main();
}
