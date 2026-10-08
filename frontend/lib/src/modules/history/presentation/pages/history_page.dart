import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/history/presentation/controllers/history_controller.dart';
import 'package:agrocampo/src/modules/history/presentation/formatters/history_detail_formatter.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _editableLaborTypes = {
  'fertilization',
  'diseaseAndPestControl',
  'cultivation',
  'sowing',
  'pruning',
  'other',
  'irrigation',
};

/// master.md: Historial, estados vacíos y componentes Material existentes.
final class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({this.initialSectorId, super.key});
  final String? initialSectorId;
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

final class _HistoryPageState extends ConsumerState<HistoryPage> {
  HistoryEventType? _type;
  String? _sectorId, _seasonId, _owner;
  bool _sectorChosen = false;
  DateTimeRange? _dates;
  int _limit = 100;
  Object? _queryKey;
  Stream<List<HistoryEvent>>? _events;
  Stream<List<HistorySector>>? _sectors;
  HistoryFacade? _source;

  void _change(VoidCallback action) => setState(() {
    action();
    _limit = 100;
    _queryKey = null;
  });

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(unlockedOwnerIdProvider);
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final facade = ref.watch(historyControllerProvider);
    if (_owner != owner) {
      _owner = owner;
      _sectorChosen = false;
      _seasonId = null;
      _type = null;
      _dates = null;
      _limit = 100;
      _queryKey = null;
      _sectors = null;
    }
    if (owner != null && (_source != facade || _sectors == null)) {
      _source = facade;
      _sectors = facade.watchSectors(owner);
    }
    final sector = _sectorChosen
        ? _sectorId
        : widget.initialSectorId ?? agriculturalContext.sectorId;
    final key = (owner, sector, _seasonId, _type, _dates, _limit, facade);
    if (owner != null && key != _queryKey) {
      _queryKey = key;
      _events = facade.watch(
        HistoryFilter(
          ownerId: owner,
          sectorId: sector,
          seasonId: _seasonId,
          type: _type,
          from: _dates?.start,
          to: _dates == null
              ? null
              : DateTime(
                  _dates!.end.year,
                  _dates!.end.month,
                  _dates!.end.day + 1,
                ).subtract(const Duration(microseconds: 1)),
          limit: _limit + 1,
        ),
      );
    }
    return AgroPage(
      title: 'Historial',
      subtitle: 'Línea temporal agrícola',
      child: owner == null
          ? const AgroEmptyState(
              title: 'Sin historial',
              message: 'Inicia sesión para consultar tus registros.',
            )
          : StreamBuilder<List<HistoryEvent>>(
              key: ValueKey(owner),
              stream: _events,
              builder: (context, snapshot) {
                final events = snapshot.data ?? const <HistoryEvent>[];
                final visible = events.take(_limit).toList();
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _filters(sector)),
                    if (snapshot.hasError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('No fue posible cargar el historial.'),
                              TextButton(
                                onPressed: () => _change(() {}),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (!snapshot.hasData)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (events.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AgroEmptyState(
                          title: 'Sin registros para este filtro',
                          message: 'Las actividades offline aparecerán aquí inmediatamente.',
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final event = visible[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0 ||
                                  visible[index - 1].seasonId != event.seasonId)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AgroSpacing.sm,
                                  ),
                                  child: Text(
                                    event.seasonLabel ?? 'Sin temporada',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                ),
                              Card(
                                child: InkWell(
                                  onTap: () => _details(event),
                                  child: ListTile(
                                    leading: IconButton(
                                      tooltip: 'Ver detalles de ${event.title}',
                                      icon: Icon(_icon(event)),
                                      onPressed: () => _details(event),
                                    ),
                                    title: Text(event.title),
                                    subtitle: Text(
                                      [
                                        if (event.cropLabel != null)
                                          event.cropLabel!,
                                        if (event.detail?.isNotEmpty == true)
                                          event.detail!,
                                        if (sector == null)
                                          event.sectorName ?? event.sectorId,
                                        if (event.sectorRetired)
                                          'Sector retirado',
                                        HistoryDetailFormatter.status(
                                          event.status,
                                        ),
                                        HistoryDetailFormatter.date(
                                          event.occurredAt,
                                        ),
                                      ].join(' · '),
                                    ),
                                    trailing: _editable(event)
                                        ? const Icon(
                                            LucideIcons.pencil,
                                            size: AgroSizes.iconStandard,
                                          )
                                        : null,
                                    onTap: _editable(event)
                                        ? () => context.push(
                                            AppRoutes.laborEdit(event.id),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    if (!snapshot.hasError && events.length > _limit)
                      SliverToBoxAdapter(
                        child: TextButton(
                          onPressed: () => setState(() => _limit += 100),
                          child: const Text('Cargar más registros'),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _filters(String? sectorId) => Column(
    children: [
      StreamBuilder<List<HistorySector>>(
        stream: _sectors,
        builder: (context, snapshot) {
          final sectors = snapshot.data ?? const <HistorySector>[];
          final matches = sectors.where((s) => s.id == sectorId);
          final selected = matches.isEmpty ? null : matches.first;
          final seasons =
              selected?.seasons ??
              [for (final sector in sectors) ...sector.seasons];
          return Column(
            children: [
              if (snapshot.hasError)
                TextButton(
                  onPressed: () => _change(() {
                    _sectors = ref
                        .read(historyControllerProvider)
                        .watchSectors(_owner!);
                  }),
                  child: const Text('Reintentar carga de sectores'),
                ),
              DropdownButtonFormField<String>(
                key: ValueKey(('sector', sectorId, sectors.length)),
                initialValue: selected?.id ?? '__all__',
                decoration: const InputDecoration(labelText: 'Sector'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: '__all__',
                    child: Text('Todos los sectores'),
                  ),
                  for (final sector in sectors)
                    DropdownMenuItem(
                      value: sector.id,
                      child: Text(
                        '${sector.name}${sector.retired ? ' · Retirado' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => _change(() {
                  _sectorChosen = true;
                  _sectorId = value == '__all__' ? null : value;
                  _seasonId = null;
                }),
              ),
              const SizedBox(height: AgroSpacing.sm),
              DropdownButtonFormField<String>(
                key: ValueKey(('season', _seasonId, seasons.length)),
                initialValue: seasons.any((s) => s.id == _seasonId)
                    ? _seasonId
                    : '__all__',
                decoration: const InputDecoration(labelText: 'Temporada'),
                isExpanded: true,
                items: [
                  const DropdownMenuItem(
                    value: '__all__',
                    child: Text('Todas las temporadas'),
                  ),
                  for (final season in seasons)
                    DropdownMenuItem(
                      value: season.id,
                      child: Text(season.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => _change(
                  () => _seasonId = value == '__all__' ? null : value,
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: AgroSpacing.sm),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(null, 'Todo'),
            _chip(HistoryEventType.labor, 'Labores'),
            _chip(HistoryEventType.cropAssignment, 'Cultivos'),
            _chip(HistoryEventType.soil, 'Suelo'),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: _pickDates,
              icon: const Icon(LucideIcons.calendar),
              label: Text(
                _dates == null
                    ? 'Filtrar por fechas'
                    : '${HistoryDetailFormatter.date(_dates!.start)} – ${HistoryDetailFormatter.date(_dates!.end)}',
              ),
            ),
          ),
          if (_dates != null)
            IconButton(
              tooltip: 'Quitar filtro de fechas',
              onPressed: () => _change(() => _dates = null),
              icon: const Icon(LucideIcons.x),
            ),
        ],
      ),
    ],
  );
  Widget _chip(HistoryEventType? type, String label) => Padding(
    padding: const EdgeInsets.only(right: AgroSpacing.xs),
    child: FilterChip(
      label: Text(label),
      selected: _type == type,
      onSelected: (_) => _change(() => _type = type),
    ),
  );
  Future<void> _pickDates() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: _dates,
    );
    if (result != null && mounted) _change(() => _dates = result);
  }

  bool _editable(HistoryEvent event) =>
      !event.sectorRetired &&
      event.type == HistoryEventType.labor &&
      event.status == 'recorded' &&
      _editableLaborTypes.contains(event.laborType);
  IconData _icon(HistoryEvent event) => switch (event.type) {
    HistoryEventType.labor => LucideIcons.wheat,
    HistoryEventType.cropAssignment => LucideIcons.leaf,
    HistoryEventType.soil => LucideIcons.flaskConical,
  };
  void _details(HistoryEvent event) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(event.title),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final field in HistoryDetailFormatter.fields(event).entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AgroSpacing.sm),
              child: SelectableText('${field.key}: ${field.value}'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
