import 'dart:convert';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/map/data/location_gateway.dart';
import 'package:agrocampo/features/map/domain/sector_geometry_draft.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

final class TerritoryMapPage extends ConsumerStatefulWidget {
  const TerritoryMapPage({super.key, this.initialParcelId, this.tileProvider});

  final String? initialParcelId;
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
  static const _openStreetMapTiles = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
  static const _userAgentPackageName = 'cl.agrocampo.app';
  static const _openStreetMapAttribution =
      'https://www.openstreetmap.org/copyright';

  SectorGeometryDraft? _draft;
  String? _editingId;
  final MapController _controller = MapController();
  final GlobalKey _mapKey = GlobalKey();
  int? _draggingVertex;
  int? _selectedVertex;
  GeoPoint? _draggedPoint;
  bool _tileLoadFailed = false;

  @override
  void initState() {
    super.initState();
    final parcelId = widget.initialParcelId;
    if (parcelId != null) {
      Future<void>.microtask(() async {
        final current = ref.read(agriculturalContextControllerProvider);
        if (current.parcelId == parcelId) return;
        try {
          await ref
              .read(agriculturalContextControllerProvider.notifier)
              .selectParcel(parcelId);
        } on Object {
          // The existing context remains usable if a stale deep link targets a
          // parcel that no longer exists locally.
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(agriculturalContextControllerProvider);
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
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
            child: ownerId == null || scope.parcelId == null
                ? const Center(child: Text('Selecciona una parcela activa.'))
                : StreamBuilder<List<Sector>>(
                    stream:
                        (database.select(database.sectors)..where(
                              (row) =>
                                  row.ownerId.equals(ownerId) &
                                  row.parcelId.equals(scope.parcelId!) &
                                  row.deletedAt.isNull(),
                            ))
                            .watch(),
                    builder: (context, snapshot) {
                      final sectors = snapshot.data ?? const [];
                      return Column(
                        children: [
                          _sectorTextAlternative(sectors, scope.sectorId),
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
                                            'Los tiles no están disponibles. Las geometrías locales siguen visibles y editables.',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                _toolbar(sectors, ownerId, scope.parcelId!),
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

  Widget _sectorTextAlternative(List<Sector> sectors, String? selectedId) {
    if (sectors.isEmpty) {
      return const SizedBox(
        height: AgroSizes.sectorSelectorRow,
        child: Center(
          child: Text('Aún no hay cuadrantes. Puedes dibujar el primero.'),
        ),
      );
    }
    return Semantics(
      container: true,
      label: 'Lista textual de cuadrantes guardados',
      child: SizedBox(
        height: AgroSizes.sectorSelectorRow,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AgroSpacing.md),
          scrollDirection: Axis.horizontal,
          itemCount: sectors.length,
          separatorBuilder: (_, _) => const SizedBox(width: AgroSpacing.xs),
          itemBuilder: (context, index) {
            final sector = sectors[index];
            return ChoiceChip(
              key: ValueKey(sector.id),
              label: Text('Cuadrante ${sector.number}'),
              selected: sector.id == selectedId,
              onSelected: (_) => ref
                  .read(agriculturalContextControllerProvider.notifier)
                  .selectSector(sector.id),
            );
          },
        ),
      ),
    );
  }

  Widget _map(List<Sector> sectors, String? selectedId) {
    final draftPoints = _visibleDraftPoints;
    return Semantics(
      label: 'Mapa territorial de OpenStreetMap con geometrías locales',
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
              urlTemplate: _openStreetMapTiles,
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
                      points: _latLng(_decode(sector.polygonJson)),
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
                source: const Text('OpenStreetMap contributors'),
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

  void _handleMapTap(LatLng point, List<Sector> sectors) {
    final geoPoint = GeoPoint(point.latitude, point.longitude);
    if (_draft != null) {
      setState(() {
        _draft!.add(geoPoint);
        _selectedVertex = _draft!.points.length - 1;
      });
      return;
    }
    for (final sector in sectors.reversed) {
      if (!PolygonGeometry.contains(geoPoint, _decode(sector.polygonJson))) {
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
    final opened = await launchUrl(
      Uri.parse(_openStreetMapAttribution),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir la atribución.')),
      );
    }
  }

  Widget _toolbar(List<Sector> sectors, String ownerId, String parcelId) {
    final selectedId = ref
        .watch(agriculturalContextControllerProvider)
        .sectorId;
    final matches = sectors.where((row) => row.id == selectedId).toList();
    final selected = matches.isEmpty ? null : matches.first;
    final error = _draft?.validationError;
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
              Text(
                _draft == null
                    ? selected == null
                          ? 'Ningún cuadrante seleccionado'
                          : 'Cuadrante ${selected.number}'
                    : error == null
                    ? '${PolygonGeometry.areaSquareMeters(_draft!.points).toStringAsFixed(0)} m²'
                    : _errorLabel(error),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_draft != null &&
                      _selectedVertex != null &&
                      _selectedVertex! < _draft!.points.length)
                    Expanded(
                      child: Text(
                        'Vértice ${_selectedVertex! + 1} seleccionado · ajuste aproximado de 1 m',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              if (_draft != null &&
                  _selectedVertex != null &&
                  _selectedVertex! < _draft!.points.length)
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
                      icon: const Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al norte',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: .00001,
                        longitudeDelta: 0,
                      ),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al sur',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: -.00001,
                        longitudeDelta: 0,
                      ),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    IconButton(
                      tooltip: 'Mover vértice al este',
                      onPressed: () => _nudgeSelectedVertex(
                        latitudeDelta: 0,
                        longitudeDelta: .00001,
                      ),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AgroSpacing.xs,
                runSpacing: AgroSpacing.xs,
                children: [
                  IconButton(
                    tooltip: 'Usar mi ubicación',
                    onPressed: _locate,
                    icon: const Icon(Icons.my_location),
                  ),
                  if (_draft != null) ...[
                    IconButton(
                      tooltip: 'Deshacer',
                      onPressed: _draft!.canUndo
                          ? () => setState(_draft!.undo)
                          : null,
                      icon: const Icon(Icons.undo),
                    ),
                    IconButton(
                      tooltip: 'Quitar último punto',
                      onPressed: _draft!.points.isEmpty
                          ? null
                          : _removeLastPoint,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    TextButton(
                      onPressed: _cancel,
                      child: const Text('Cancelar'),
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: selected == null
                          ? null
                          : () => context.push(AppRoutes.sector(selected.id)),
                      icon: const Icon(Icons.open_in_new_outlined),
                      label: const Text('Ver cuadrante'),
                    ),
                    TextButton.icon(
                      onPressed: selected == null
                          ? null
                          : () => setState(() {
                              final points = _decode(selected.polygonJson);
                              _editingId = selected.id;
                              _selectedVertex = points.isEmpty ? null : 0;
                              _draft = SectorGeometryDraft(points);
                            }),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ],
                  FilledButton(
                    onPressed: _draft == null
                        ? () => setState(() {
                            _selectedVertex = null;
                            _draft = SectorGeometryDraft();
                          })
                        : error == null
                        ? () => _save(sectors, ownerId, parcelId)
                        : null,
                    child: Text(
                      _draft == null ? 'Nuevo cuadrante' : 'Confirmar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    List<Sector> sectors,
    String ownerId,
    String parcelId,
  ) async {
    final existing = sectors.where((row) => row.id == _editingId).toList();
    final highest = sectors.fold<int>(
      0,
      (value, row) => row.number > value ? row.number : value,
    );
    final row = existing.isEmpty ? null : existing.first;
    final id = await SectorRepository(ref.read(appDatabaseProvider)).save(
      ownerId: ownerId,
      parcelId: parcelId,
      id: row?.id,
      number: row?.number ?? highest + 1,
      name: row?.name ?? 'Sector ${highest + 1}',
      kind: row?.kind ?? 'crop',
      polygon: _draft!.confirm(),
    );
    await ref
        .read(agriculturalContextControllerProvider.notifier)
        .selectSector(id);
    if (!mounted) return;
    _cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Geometría guardada en este dispositivo.')),
    );
  }

  void _cancel() => setState(() {
    _draft?.cancel();
    _draft = null;
    _editingId = null;
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
      final point = await GeolocatorLocationGateway().currentPosition();
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

  static List<GeoPoint> _decode(String source) =>
      (jsonDecode(source) as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(
            (point) => GeoPoint(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            ),
          )
          .toList(growable: false);

  static List<LatLng> _latLng(List<GeoPoint> points) =>
      points.map(_latLngPoint).toList(growable: false);

  static LatLng _latLngPoint(GeoPoint point) =>
      LatLng(point.latitude, point.longitude);
}
