import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:flutter/material.dart';

final class FoundationPlaceholderPage extends StatelessWidget {
  const FoundationPlaceholderPage({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => AgroPage(
    title: title,
    child: AgroEmptyState(title: title, message: message),
  );
}
