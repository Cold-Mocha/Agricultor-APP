import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/polygon_geometry.dart';

enum SectorGeometryDraftState { editing, cancelled, confirmed }

final class SectorGeometryDraft {
  SectorGeometryDraft([Iterable<GeoPoint> initial = const []])
    : _original = List.unmodifiable(initial),
      _points = List.of(initial);

  final List<GeoPoint> _original;
  final List<GeoPoint> _points;
  final List<List<GeoPoint>> _undo = [];
  SectorGeometryDraftState _state = SectorGeometryDraftState.editing;

  List<GeoPoint> get points => List.unmodifiable(_points);
  bool get isDirty => !_same(_points, _original);
  bool get canUndo => _undo.isNotEmpty;
  SectorGeometryDraftState get state => _state;
  bool get isEditing => _state == SectorGeometryDraftState.editing;
  String? get validationError => PolygonGeometry.validationError(_points);

  void add(GeoPoint point) => _change(() => _points.add(point));

  void move(int index, GeoPoint point) => _change(() => _points[index] = point);

  void remove(int index) => _change(() => _points.removeAt(index));

  void clear() => _change(_points.clear);

  void undo() {
    if (_undo.isEmpty) return;
    final previous = _undo.removeLast();
    _points
      ..clear()
      ..addAll(previous);
  }

  void cancel() {
    _points
      ..clear()
      ..addAll(_original);
    _undo.clear();
    _state = SectorGeometryDraftState.cancelled;
  }

  List<GeoPoint> confirm() {
    final error = validationError;
    if (error != null) throw StateError(error);
    _state = SectorGeometryDraftState.confirmed;
    return PolygonGeometry.normalize(_points);
  }

  void _change(void Function() mutation) {
    if (!isEditing) throw StateError('geometry_draft_closed');
    _undo.add(List.of(_points));
    mutation();
  }

  static bool _same(List<GeoPoint> a, List<GeoPoint> b) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (a[index].latitude != b[index].latitude ||
          a[index].longitude != b[index].longitude) {
        return false;
      }
    }
    return true;
  }
}
