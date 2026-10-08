import 'package:uuid/uuid.dart';

extension type const EntityId(String value) {
  factory EntityId.generate() => EntityId(const Uuid().v7());

  bool get isValid => Uuid.isValidUUID(fromString: value);
}
