import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
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
