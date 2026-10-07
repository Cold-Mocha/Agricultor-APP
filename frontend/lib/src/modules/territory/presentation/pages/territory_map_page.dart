import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/crop_cycles_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class TerritoryMapPage extends ConsumerStatefulWidget {
  const TerritoryMapPage({super.key, this.tileProvider});

  final TileProvider? tileProvider;

  @override
  ConsumerState<TerritoryMapPage> createState() => _TerritoryMapPageState();
}

final class _TerritoryMapPageState extends ConsumerState<TerritoryMapPage> {
  static const _initialLatitude = String.fromEnvironment(
    'MAP_INITIAL_LATITUDE',
    defaultValue: '-38.7363',
  );
  static const _initialLongitude = String.fromEnvironment(
    'MAP_INITIAL_LONGITUDE',
    defaultValue: '-72.5974',
  );
  static final _initialCenter = LatLng(
    double.tryParse(_initialLatitude) ?? -38.7363,
    double.tryParse(_initialLongitude) ?? -72.5974,
  );

  /// Esri World Imagery: free satellite tiles, no API key, same guarantee
  /// OpenStreetMap had. `MAP_TILE_URL` can still override it per environment.
  static const _satelliteTiles = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
  );
  static const _userAgentPackageName = 'cl.agrocampo.app';

  SectorGeometryDraft? _draft;
  String? _editingId;
  String? _newKind;
  final MapController _controller = MapController();
  final GlobalKey _mapKey = GlobalKey();
  int? _draggingVertex;
  int? _selectedVertex;
  GeoPoint? _draggedPoint;
  bool _tileLoadFailed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(agriculturalContextControllerProvider);
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(territoryMapControllerProvider);
    return AgroPage(
      title: 'Mapa de cuadrantes',
      subtitle: _draft == null
          ? 'Selecciona un cuadrante o crea uno nuevo.'
          : 'La geometría cambia solo al confirmar.',
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AgroSpacing.md),
            child: AgriculturalContextSelector(compact: true),
          ),
          Expanded(
            child: ownerId == null
                ? const Center(
                    child: Text('Inicia sesión para ver tus cuadrantes.'),
                  )
                : StreamBuilder<List<MapSectorGeometry>>(
                    stream: controller.watchSectors(ownerId),
                    builder: (context, snapshot) {
                      final sectors = snapshot.data ?? const [];
                      return Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                _map(sectors, scope.sectorId),
                                if (_tileLoadFailed)
                                  Positioned(
                                    top: AgroSpacing.sm,
                                    left: AgroSpacing.sm,
                                    right: AgroSpacing.sm,
                                    child: Semantics(
                                      liveRegion: true,
                                      child: Material(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: .94),
                                        borderRadius: BorderRadius.circular(
                                          AgroRadii.medium,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(
                                            AgroSpacing.sm,
                                          ),
                                          child: Text(
                                            'El mapa de fondo no está disponible. Los cuadrantes siguen visibles y editables.',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                _toolbar(sectors, ownerId),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _map(List<MapSectorGeometry> sectors, String? selectedId) {
    final draftPoints = _visibleDraftPoints;
    return Semantics(
      label: 'Mapa satelital territorial con tus cuadrantes',
      child: ColoredBox(
        key: _mapKey,
        color: AgroColors.mapCanvas,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 11,
            minZoom: 3,
            maxZoom: 19,
            backgroundColor: AgroColors.mapCanvas,
            onTap: (_, point) => _handleMapTap(point, sectors),
          ),
          children: [
            TileLayer(
              urlTemplate: _satelliteTiles,
              userAgentPackageName: _userAgentPackageName,
              maxNativeZoom: 19,
              tileProvider: widget.tileProvider,
              errorTileCallback: _handleTileError,
            ),
            PolygonLayer<String>(
              polygons: [
                for (final sector in sectors)
                  if (sector.id != _editingId)
                    Polygon<String>(
                      points: _latLng(sector.polygon),
                      color: AgroColors.greenSoft.withValues(alpha: .45),
                      borderColor: sector.id == selectedId
                          ? AgroColors.brand
                          : AgroColors.muted,
                      borderStrokeWidth: sector.id == selectedId ? 4 : 3,
                      hitValue: sector.id,
                    ),
                if (draftPoints.length >= 3)
                  Polygon<String>(
                    points: _latLng(draftPoints),
                    color: AgroColors.greenSoft.withValues(alpha: .7),
                    borderColor: AgroColors.brand,
                    borderStrokeWidth: 4,
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (var index = 0; index < draftPoints.length; index++)
                  Marker(
                    key: ValueKey('draft-vertex-$index'),
                    point: _latLngPoint(draftPoints[index]),
                    width: AgroSizes.touchTarget,
                    height: AgroSizes.touchTarget,
                    child: Semantics(
                      label:
                          'Vértice ${index + 1}. Toca para seleccionar o arrastra para mover.',
                      child: Tooltip(
                        message:
                            'Selecciona o arrastra el vértice ${index + 1}',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _selectedVertex = index),
                          onPanStart: (_) => _startVertexDrag(index),
                          onPanUpdate: (details) =>
                              _updateVertexDrag(index, details.globalPosition),
                          onPanEnd: (_) => _finishVertexDrag(index),
                          onPanCancel: _cancelVertexDrag,
                          child: Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedVertex == index
                                      ? AgroColors.accent
                                      : AgroColors.brand,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: AgroColors.mapOverlayShadow,
                                  ),
                                ],
                              ),
                              child: const SizedBox.square(
                                dimension: AgroSizes.mapVertexVisual,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AgroSpacing.sm),
              child: SimpleAttributionWidget(
                source: const Text('Esri, Maxar, Earthstar Geographics'),
                onTap: _openMapAttribution,
                alignment: Alignment.topRight,
                backgroundColor: Theme.of(context).colorScheme.surface
                    .withValues(alpha: .94),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<GeoPoint> get _visibleDraftPoints {
    final points = _draft?.points.toList() ?? <GeoPoint>[];
    final index = _draggingVertex;
    final draggedPoint = _draggedPoint;
    if (index != null && draggedPoint != null && index < points.length) {
      points[index] = draggedPoint;
    }
    return points;
  }

  void _handleMapTap(LatLng point, List<MapSectorGeometry> sectors) {
    final geoPoint = GeoPoint(point.latitude, point.longitude);
    if (_draft != null) {
      setState(() {
        _draft!.add(geoPoint);
        _selectedVertex = _draft!.points.length - 1;
      });
      return;
    }
    for (final sector in sectors.reversed) {
      if (!PolygonGeometry.contains(geoPoint, sector.polygon)) {
        continue;
      }
      ref
          .read(agriculturalContextControllerProvider.notifier)
          .selectSector(sector.id);
      return;
    }
  }

  void _startVertexDrag(int index) => setState(() {
    _draggingVertex = index;
    _selectedVertex = index;
    _draggedPoint = _draft!.points[index];
  });

  void _updateVertexDrag(int index, Offset globalPosition) {
    if (_draggingVertex != index) return;
    final renderBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final point = _controller.camera.screenOffsetToLatLng(
      renderBox.globalToLocal(globalPosition),
    );
    setState(() => _draggedPoint = GeoPoint(point.latitude, point.longitude));
  }

  void _finishVertexDrag(int index) => setState(() {
    final point = _draggedPoint;
    if (_draggingVertex == index && point != null) {
      _draft!.move(index, point);
    }
    _draggingVertex = null;
    _draggedPoint = null;
  });

  void _cancelVertexDrag() => setState(() {
    _draggingVertex = null;
    _draggedPoint = null;
  });

  void _handleTileError(TileImage _, Object _, StackTrace? _) {
    if (_tileLoadFailed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_tileLoadFailed) {
        setState(() => _tileLoadFailed = true);
      }
    });
  }

  Future<void> _openMapAttribution() async {
    final opened = await ref
        .read(territoryMapControllerProvider)
        .openAttribution();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir la atribución.')),
      );
    }
  }

  /// Fine vertex nudging is an editing aid; new quadrants are drawn by tap.
  bool get _canNudgeVertex =>
      _draft != null &&
      _editingId != null &&
      _selectedVertex != null &&
      _selectedVertex! < _draft!.points.length;

  Widget _toolbar(List<MapSectorGeometry> sectors, String ownerId) {
    final selectedId = ref
        .watch(agriculturalContextControllerProvider)
        .sectorId;
    final matches = sectors.where((row) => row.id == selectedId).toList();
    final selected = matches.isEmpty ? null : matches.first;
    final error = _draft?.validationError;
    if (_draft == null && selected == null) {
      // Nothing to describe yet: only the primary action floats on the map.
      return Positioned(
        left: AgroSpacing.md,
        right: AgroSpacing.md,
        bottom: AgroSpacing.md,
        child: Center(
          child: FilledButton(
            onPressed: _startNewQuadrant,
            child: const Text('Nuevo cuadrante'),
          ),
        ),
      );
    }
    return Positioned(
      left: AgroSpacing.md,
      right: AgroSpacing.md,
      bottom: AgroSpacing.md,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AgroSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // While fewer than three points exist the drawing itself is the
              // guidance, so no status line is shown.
              if (error != 'polygon_requires_three_points' &&
                  (_draft != null || selected != null))
                Text(
                  _draft == null
                      ? 'Cuadrante ${selected!.number}'
                      : error == null
                      ? 'Tamaño cuadrante: ${PolygonGeometry.areaSquareMeters(_draft!.points).toStringAsFixed(0)} m²'
                      : _errorLabel(error),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_canNudgeVertex)
                    Expanded(
                      child: Text(
                        'Vértice ${_selectedVertex! + 1} seleccionado · ajuste aproximado de 1 m',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              if (_canNudgeVertex)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AgroSpacing.xs,
                  children: [
                    IconButton(
                      tooltip: 'Mover vértice al oeste',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: 0,
                        longitudeDelta: -.00001,
                      ),
                      icon: const Icon(LucideIcons.arrowLeft),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al norte',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: .00001,
                        longitudeDelta: 0,
                      ),
                      icon: const Icon(LucideIcons.arrowUp),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al sur',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: -.00001,
                        longitudeDelta: 0,
                      ),
                      icon: const Icon(LucideIcons.arrowDown),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al este',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: 0,
                        longitudeDelta: .00001,
                      ),
                      icon: const Icon(LucideIcons.arrowRight),
                    ),
                  ],
                ),
              if (_draft != null) ...[
                // Drawing tools first, then the category and the decision.
                // Smaller glyphs, but each keeps the 48 dp touch target.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AgroSpacing.xl,
                  children: [
                    IconButton(
                      tooltip: 'Usar mi ubicación',
                      iconSize: AgroSizes.iconStandard,
                      onPressed: _locate,
                      icon: const Icon(LucideIcons.locateFixed),
                    ),
                    IconButton(
                      tooltip: 'Deshacer',
                      iconSize: AgroSizes.iconStandard,
                      onPressed: _draft!.canUndo
                          ? () => setState(_draft!.undo)
                          : null,
                      icon: const Icon(LucideIcons.undo2),
                    ),
                    IconButton(
                      tooltip: 'Quitar último punto',
                      iconSize: AgroSizes.iconStandard,
                      onPressed: _draft!.points.isEmpty
                          ? null
                          : _removeLastPoint,
                      icon: const Icon(LucideIcons.circleMinus),
                    ),
                  ],
                ),
                if (_editingId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AgroSpacing.xs,
                    ),
                    child: _KindSegmentedControl(
                      value: _newKind,
                      onChanged: (value) => setState(() => _newKind = value),
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AgroSpacing.xs,
                  runSpacing: AgroSpacing.xs,
                  children: [
                    FilledButton(
                      onPressed:
                          error == null &&
                              (_editingId != null || _newKind != null)
                          ? () => _save(sectors, ownerId)
                          : null,
                      child: const Text('Confirmar'),
                    ),
                    TextButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ] else
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AgroSpacing.xs,
                  runSpacing: AgroSpacing.xs,
                  children: [
                    if (selected != null) ...[
                      // Hidden instead of disabled: without a selected
                      // quadrant there is nothing to open or edit.
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.sector(selected.id)),
                        icon: const Icon(LucideIcons.externalLink),
                        label: const Text('Ver cuadrante'),
                      ),
                      TextButton.icon(
                        onPressed: () => setState(() {
                          final points = selected.polygon;
                          _editingId = selected.id;
                          _selectedVertex = points.isEmpty ? null : 0;
                          _draft = SectorGeometryDraft(points);
                        }),
                        icon: const Icon(LucideIcons.pencil),
                        label: const Text('Editar'),
                      ),
                    ],
                    FilledButton(
                      onPressed: _startNewQuadrant,
                      child: const Text('Nuevo cuadrante'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(List<MapSectorGeometry> sectors, String ownerId) async {
    final created = _editingId == null;
    // A crop quadrant only exists with its crop: choose it before saving.
    CropRef? crop;
    if (created && _newKind == 'crop') {
      crop = await pickInitialCrop(context, ref, ownerId: ownerId);
      if (!mounted) return;
      if (crop == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Elige un cultivo para crear el cuadrante.'),
          ),
        );
        return;
      }
    }
    final id = await ref
        .read(territoryMapControllerProvider)
        .saveGeometry(
          ownerId: ownerId,
          input: MapGeometryFormInput(
            sectorId: _editingId,
            kind: _editingId == null ? _newKind : null,
            polygon: _draft!.confirm(),
          ),
        );
    var message = 'Geometría guardada en este dispositivo.';
    if (crop != null) {
      try {
        await ref
            .read(cropsControllerProvider)
            .assignInitialCrop(ownerId: ownerId, sectorId: id, crop: crop);
        message = 'Cuadrante guardado con ${crop.label} como cultivo.';
      } on Object {
        // Without its crop the new quadrant is removed instead of kept empty.
        await ref.read(sectorDetailControllerProvider(id)).delete(ownerId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo asignar el cultivo, así que el cuadrante no se creó.',
            ),
          ),
        );
        return;
      }
    }
    await ref
        .read(agriculturalContextControllerProvider.notifier)
        .selectSector(id);
    if (!mounted) return;
    _cancel();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    // A new quadrant lands in "Tus cuadrantes"; edits stay on the map.
    if (created) context.go(AppRoutes.sectors);
  }

  void _startNewQuadrant() => setState(() {
    _selectedVertex = null;
    // Most quadrants are crops; apiary stays one tap away.
    _newKind = 'crop';
    _draft = SectorGeometryDraft();
  });

  void _cancel() => setState(() {
    _draft?.cancel();
    _draft = null;
    _editingId = null;
    _newKind = null;
    _draggingVertex = null;
    _selectedVertex = null;
    _draggedPoint = null;
  });

  void _removeLastPoint() => setState(() {
    final lastIndex = _draft!.points.length - 1;
    _draft!.remove(lastIndex);
    if (_selectedVertex == lastIndex) {
      _selectedVertex = _draft!.points.isEmpty
          ? null
          : _draft!.points.length - 1;
    }
  });

  void _nudgeSelectedVertex({
    required double latitudeDelta,
    required double longitudeDelta,
  }) => setState(() {
    final index = _selectedVertex;
    if (index == null || index >= _draft!.points.length) return;
    final point = _draft!.points[index];
    _draft!.move(
      index,
      GeoPoint(
        point.latitude + latitudeDelta,
        point.longitude + longitudeDelta,
      ),
    );
  });

  Future<void> _locate() async {
    try {
      final point = await ref.read(territoryMapControllerProvider).locate();
      _controller.move(_latLngPoint(point), 17);
    } on Object catch (error) {
      if (!mounted) return;
      final denied = '$error'.contains('permission');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            denied
                ? 'Permiso de ubicación denegado. Puedes dibujar manualmente.'
                : 'Ubicación no disponible. Puedes dibujar manualmente.',
          ),
        ),
      );
    }
  }

  static String _errorLabel(String value) => switch (value) {
    'polygon_requires_three_points' => 'Agrega al menos tres puntos.',
    'polygon_self_intersects' => 'El contorno no puede cruzarse.',
    'polygon_area_zero' => 'El cuadrante debe cubrir una superficie.',
    'polygon_has_duplicate_points' => 'Elimina puntos repetidos.',
    _ => 'Revisa la geometría.',
  };

  static List<LatLng> _latLng(List<GeoPoint> points) =>
      points.map(_latLngPoint).toList(growable: false);

  static LatLng _latLngPoint(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);
}

/// Pill-shaped category switch for a new quadrant (`master.md`, chips y
/// selectores): the selected segment uses `brand` with white text.
final class _KindSegmentedControl extends StatelessWidget {
  const _KindSegmentedControl({required this.value, required this.onChanged});

  static const _options = [('crop', 'Vegetal'), ('apiary', 'Apícola')];

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = _options.indexWhere((option) => option.$1 == value);
    return Semantics(
      label: 'Categoría del cuadrante',
      container: true,
      child: Container(
        height: AgroSizes.touchTarget,
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(AgroSpacing.xxs),
        decoration: BoxDecoration(
          color: AgroColors.greenSoft,
          borderRadius: BorderRadius.circular(AgroRadii.full),
          border: Border.all(color: AgroColors.line, width: 1.5),
        ),
        child: Stack(
          children: [
            if (index >= 0)
              AnimatedAlign(
                duration: AgroMotion.standard,
                curve: Curves.easeOutCubic,
                alignment: index == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 1 / _options.length,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AgroColors.brand,
                      borderRadius: BorderRadius.circular(AgroRadii.full),
                      boxShadow: const [
                        BoxShadow(
                          color: AgroColors.mapOverlayShadow,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                for (final (code, label) in _options)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: code == value,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AgroRadii.full),
                        onTap: () => onChanged(code),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: AgroMotion.quick,
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: code == value
                                      ? Colors.white
                                      : AgroColors.ink,
                                ),
                            child: Text(label),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
