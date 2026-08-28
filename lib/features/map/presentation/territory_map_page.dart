import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/geometry/polygon_geometry.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/map/data/location_gateway.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final class TerritoryMapPage extends ConsumerStatefulWidget {
  const TerritoryMapPage({super.key});

  @override
  ConsumerState<TerritoryMapPage> createState() => _TerritoryMapPageState();
}

final class _TerritoryMapPageState extends ConsumerState<TerritoryMapPage> {
  final _points = <LatLng>[];
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final geoPoints = _points
        .map((point) => GeoPoint(point.latitude, point.longitude))
        .toList(growable: false);
    final area = PolygonGeometry.areaSquareMeters(geoPoints);
    return AgroPage(
      title: 'Mapa',
      subtitle: 'Toca al menos tres puntos para delimitar un sector.',
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-38.7397, -72.5984),
              zoom: 11,
            ),
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) => _controller = controller,
            onTap: (point) => setState(() => _points.add(point)),
            polygons: {
              if (_points.length >= 3)
                Polygon(
                  polygonId: const PolygonId('draft-sector'),
                  points: _points,
                  fillColor: AgroColors.greenSoft.withValues(alpha: .6),
                  strokeColor: AgroColors.brand,
                  strokeWidth: 3,
                ),
            },
          ),
          Positioned(
            left: AgroSpacing.md,
            right: AgroSpacing.md,
            bottom: AgroSpacing.md,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AgroSpacing.md),
                child: Column(
                  children: [
                    Text(
                      _points.length < 3
                          ? '${_points.length}/3 puntos mínimos'
                          : '${area.toStringAsFixed(0)} m²',
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _locate,
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Usar mi ubicación',
                        ),
                        TextButton(
                          onPressed: _points.isEmpty
                              ? null
                              : () => setState(_points.clear),
                          child: const Text('Limpiar'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: _points.length < 3 ? null : _saveSector,
                          child: const Text('Guardar sector'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _locate() async {
    final point = await GeolocatorLocationGateway().currentPosition();
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(point.latitude, point.longitude), 17),
    );
  }

  Future<void> _saveSector() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null) return;
    final parcel =
        await (database.select(database.parcels)..where(
              (row) => row.ownerId.equals(ownerId) & row.isActive.equals(true),
            ))
            .getSingleOrNull();
    if (parcel == null) return;
    final existing = await (database.select(
      database.sectors,
    )..where((row) => row.parcelId.equals(parcel.id))).get();
    await SectorRepository(database).save(
      ownerId: ownerId,
      parcelId: parcel.id,
      number: existing.length + 1,
      name: 'Sector ${existing.length + 1}',
      polygon: _points
          .map((point) => GeoPoint(point.latitude, point.longitude))
          .toList(growable: false),
    );
    if (!mounted) return;
    setState(_points.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sector guardado localmente.')),
    );
  }
}
