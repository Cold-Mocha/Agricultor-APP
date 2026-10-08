import 'dart:io';

final RegExp _directivePattern = RegExp(
  r'''(?:import|export|part)\s+['"]([^'"]+)['"]''',
);

void main() {
  final root = _workspaceRoot();
  final violations = <String>[];
  final frontendLib = Directory('${root.path}/frontend/lib');
  final backendLib = Directory('${root.path}/backend/lib');

  final frontendFiles = _dartFiles(frontendLib);
  final backendFiles = _dartFiles(backendLib);

  _checkPackageEntrypoints(root, violations);
  _checkGenericDirectories(frontendLib, violations);
  _checkGenericDirectories(backendLib, violations);
  _checkFrontend(frontendFiles, violations);
  _checkBackend(backendFiles, violations);
  _checkPublicBackendApi(root, violations);
  _checkNoParallel003Module(root, violations);
  _checkModuleCycles(
    frontendFiles,
    label: 'frontend',
    moduleForFile: (file) => _frontendModule(file.path),
    moduleForDirective: _frontendModuleFromDirective,
    violations: violations,
  );
  _checkModuleCycles(
    backendFiles,
    label: 'backend',
    moduleForFile: (file) => _backendModule(file.path),
    moduleForDirective: _backendModuleFromDirective,
    violations: violations,
  );

  violations.sort();
  if (violations.isNotEmpty) {
    stderr.writeln('Architecture check failed (${violations.length}):');
    for (final violation in violations) {
      stderr.writeln(' - $violation');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Architecture check passed.');
}

void _checkNoParallel003Module(Directory root, List<String> violations) {
  final forbidden = <String>[
    '${root.path}/frontend/lib/src/modules/003',
    '${root.path}/backend/lib/src/modules/003',
  ];
  for (final path in forbidden) {
    if (Directory(path).existsSync()) {
      violations.add('${_normalized(path)}: parallel code module 003 is forbidden');
    }
  }
}

Directory _workspaceRoot() {
  var candidate = Directory.current.absolute;
  while (true) {
    final pubspec = File('${candidate.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('workspace:')) {
      return candidate;
    }
    final parent = candidate.parent;
    if (parent.path == candidate.path) {
      throw StateError('Pub workspace root not found.');
    }
    candidate = parent;
  }
}

List<File> _dartFiles(Directory root) => root
    .listSync(recursive: true, followLinks: false)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'))
    .toList(growable: false);

Iterable<String> _directives(File file) sync* {
  final source = file.readAsStringSync();
  for (final match in _directivePattern.allMatches(source)) {
    yield match.group(1)!;
  }
}

String _normalized(String path) => path.replaceAll('\\', '/');

String? _frontendModule(String path) =>
    RegExp(r'/frontend/lib/src/modules/([^/]+)/')
        .firstMatch(_normalized(path))
        ?.group(1);

String? _backendModule(String path) =>
    RegExp(r'/backend/lib/src/modules/([^/]+)/')
        .firstMatch(_normalized(path))
        ?.group(1);

String? _moduleFromUri(String uri) =>
    RegExp(r'^package:agrocampo_backend/src/modules/([^/]+)/')
        .firstMatch(uri)
        ?.group(1);

String? _frontendModuleFromDirective(File source, String uri) {
  final packageMatch = RegExp(r'^package:agrocampo/src/modules/([^/]+)/')
      .firstMatch(uri);
  if (packageMatch != null) return packageMatch.group(1);
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;
  return _frontendModule(File.fromUri(source.absolute.uri.resolve(uri)).path);
}

String? _backendModuleFromDirective(File source, String uri) {
  final packageModule = _moduleFromUri(uri);
  if (packageModule != null) return packageModule;
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;
  return _backendModule(File.fromUri(source.absolute.uri.resolve(uri)).path);
}

String? _resolvedBackendPath(File source, String uri) {
  if (uri.startsWith('package:agrocampo_backend/')) {
    final backendLib =
        source.path.split('/backend/lib/').first + '/backend/lib';
    return _normalized(
      '$backendLib/${uri.substring('package:agrocampo_backend/'.length)}',
    );
  }
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;
  return _normalized(File.fromUri(source.absolute.uri.resolve(uri)).path);
}

void _checkPackageEntrypoints(Directory root, List<String> violations) {
  if (Directory('${root.path}/lib').existsSync()) {
    violations.add('root lib/: production code is forbidden at workspace root');
  }
  _checkDirectDartChildren(
    Directory('${root.path}/frontend/lib'),
    const {'main.dart'},
    'frontend/lib',
    violations,
  );
  _checkDirectDartChildren(
    Directory('${root.path}/backend/lib'),
    const {'agrocampo_backend.dart'},
    'backend/lib',
    violations,
  );
}

void _checkDirectDartChildren(
  Directory directory,
  Set<String> allowed,
  String label,
  List<String> violations,
) {
  for (final file in directory.listSync().whereType<File>()) {
    if (file.path.endsWith('.dart') &&
        !allowed.contains(file.uri.pathSegments.last)) {
      violations.add(
        '$label/${file.uri.pathSegments.last}: unexpected package entrypoint',
      );
    }
  }
}

void _checkGenericDirectories(Directory root, List<String> violations) {
  const forbidden = {'utils', 'services', 'types'};
  for (final entity in root.listSync(recursive: true).whereType<Directory>()) {
    final name = entity.uri.pathSegments.where((part) => part.isNotEmpty).last;
    if (forbidden.contains(name)) {
      violations.add(
        '${_normalized(entity.path)}: generic directory "$name" is forbidden',
      );
    }
  }
}

void _checkFrontend(List<File> files, List<String> violations) {
  for (final file in files) {
    final path = _normalized(file.path);
    final sourceModule = _frontendModule(file.path);
    final isShared = path.contains('/frontend/lib/src/shared/');
    for (final uri in _directives(file)) {
      if ((uri.startsWith('package:agrocampo_backend/') &&
              uri != 'package:agrocampo_backend/agrocampo_backend.dart') ||
          uri.contains('backend/lib/src')) {
        violations.add(
          '${_normalized(file.path)}: imports private Backend API $uri',
        );
      }
      final targetMatch = RegExp(
        r'^package:agrocampo/src/modules/([^/]+)/(.+)$',
      ).firstMatch(uri);
      final targetModule = _frontendModuleFromDirective(file, uri);
      if (isShared && targetModule != null) {
        violations.add('$path: shared depends on feature $targetModule');
      }
      if (sourceModule == null ||
          targetModule == null ||
          sourceModule == targetModule) {
        continue;
      }
      final isPublicBarrel = targetMatch?.group(2) == '${targetModule}_ui.dart';
      if (!isPublicBarrel) {
        violations.add('$path: imports internal Frontend module path $uri');
      }
    }
  }
}

void _checkBackend(List<File> files, List<String> violations) {
  for (final file in files) {
    final path = _normalized(file.path);
    final sourceModule = _backendModule(path);
    final isDomain = path.contains('/domain/');
    final isShared = path.contains('/backend/lib/src/shared/');
    final isPlatform = path.contains('/backend/lib/src/platform/');
    for (final uri in _directives(file)) {
      if (uri.startsWith('package:agrocampo/')) {
        violations.add('$path: Backend imports Frontend $uri');
      }
      if (uri == 'package:flutter/widgets.dart' ||
          uri == 'package:flutter/material.dart' ||
          uri == 'package:flutter/cupertino.dart' ||
          uri.startsWith('package:go_router/')) {
        violations.add('$path: Backend imports UI/navigation framework $uri');
      }
      final targetModule = _backendModuleFromDirective(file, uri);
      final targetPath = _resolvedBackendPath(file, uri);
      if (isDomain &&
          uri.startsWith('package:') &&
          !uri.startsWith('package:agrocampo_backend/')) {
        violations.add('$path: pure domain imports external package $uri');
      }
      if (isDomain &&
          targetPath != null &&
          !targetPath.contains('/domain/') &&
          !targetPath.contains('/shared/')) {
        violations.add('$path: domain depends on non-domain code $uri');
      }
      if (isShared && targetModule != null) {
        violations.add('$path: shared depends on feature $targetModule');
      }
      if (isShared &&
          targetPath != null &&
          (targetPath.contains('/platform/') ||
              targetPath.contains('/infrastructure/'))) {
        violations.add('$path: shared depends on infrastructure $uri');
      }
      if (isPlatform && targetModule != null) {
        final allowedDatabaseImport =
            path.endsWith('/platform/database/app_database.dart') &&
            targetPath != null &&
            RegExp(
              r'/backend/lib/src/modules/[^/]+/infrastructure/persistence/tables/.+\.dart$',
            ).hasMatch(targetPath);
        if (!allowedDatabaseImport) {
          violations.add(
            '$path: platform depends on feature outside AppDatabase table exception: $uri',
          );
        }
      }
      if (sourceModule == null ||
          targetModule == null ||
          sourceModule == targetModule) {
        continue;
      }
      if (targetPath != null &&
          (targetPath.contains('/infrastructure/') ||
              targetPath.contains('/application/controllers/') ||
              targetPath.contains('/application/facades/'))) {
        violations.add('$path: cross-feature implementation import $uri');
      }
      if (targetPath == null ||
          !targetPath.endsWith(
            '/modules/$targetModule/${targetModule}_api.dart',
          )) {
        violations.add(
          '$path: cross-feature import must use ${targetModule}_api.dart: $uri',
        );
      }
    }
  }
}

void _checkPublicBackendApi(Directory root, List<String> violations) {
  final entrypoint = File('${root.path}/backend/lib/agrocampo_backend.dart');
  final backendRoot = Directory('${root.path}/backend/lib');
  final seen = <String>{};
  final queue = <File>[entrypoint];
  while (queue.isNotEmpty) {
    final file = queue.removeLast();
    final path = _normalized(file.absolute.path);
    if (!seen.add(path)) continue;
    for (final uri in _directives(file)) {
      if (!file.readAsStringSync().contains("export '$uri") &&
          !file.readAsStringSync().contains('export "$uri')) {
        continue;
      }
      final target = _resolveBackendUri(file, backendRoot, uri);
      if (target == null || !target.existsSync()) continue;
      final targetPath = _normalized(target.absolute.path);
      if (targetPath.contains('/infrastructure/') ||
          targetPath.contains('/platform/') ||
          targetPath.endsWith('.g.dart') ||
          RegExp(r'/(tables|daos)/').hasMatch(targetPath) ||
          RegExp(r'/(repositories|gateways|codecs|outbox|cursors)/')
              .hasMatch(targetPath)) {
        violations.add(
          '${_normalized(entrypoint.path)}: public API reaches infrastructure $targetPath',
        );
        continue;
      }
      queue.add(target);
    }
  }
}

File? _resolveBackendUri(File source, Directory backendRoot, String uri) {
  if (uri.startsWith('package:agrocampo_backend/')) {
    return File(
      '${backendRoot.path}/${uri.substring('package:agrocampo_backend/'.length)}',
    );
  }
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;
  return File.fromUri(source.absolute.uri.resolve(uri));
}

void _checkModuleCycles(
  List<File> files, {
  required String label,
  required String? Function(File file) moduleForFile,
  required String? Function(File file, String uri) moduleForDirective,
  required List<String> violations,
}) {
  final graph = <String, Set<String>>{};
  for (final file in files) {
    final source = moduleForFile(file);
    if (source == null) continue;
    graph.putIfAbsent(source, () => <String>{});
    for (final uri in _directives(file)) {
      final target = moduleForDirective(file, uri);
      if (target != null && target != source) graph[source]!.add(target);
    }
  }
  final visiting = <String>{};
  final visited = <String>{};
  final stack = <String>[];
  void visit(String node) {
    if (visited.contains(node)) return;
    if (visiting.contains(node)) {
      final start = stack.indexOf(node);
      violations.add(
        '$label modules: dependency cycle ${[...stack.sublist(start), node].join(' -> ')}',
      );
      return;
    }
    visiting.add(node);
    stack.add(node);
    for (final target in graph[node] ?? const <String>{}) {
      visit(target);
    }
    stack.removeLast();
    visiting.remove(node);
    visited.add(node);
  }

  for (final node in graph.keys) {
    visit(node);
  }
}
