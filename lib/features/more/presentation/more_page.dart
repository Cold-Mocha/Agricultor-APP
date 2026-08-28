import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Más',
    child: ListView(
      children: [
        _item(context, Icons.person_outline, 'Perfil', '/perfil'),
        _item(
          context,
          Icons.notifications_outlined,
          'Recordatorios',
          '/recordatorios',
        ),
        _item(
          context,
          Icons.sync_outlined,
          'Sincronización',
          '/sincronizacion',
        ),
        _item(context, Icons.table_view_outlined, 'Exportar XLSX', '/exportar'),
      ],
    ),
  );

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(route),
  );
}
