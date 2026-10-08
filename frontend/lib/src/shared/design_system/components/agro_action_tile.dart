import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final class AgroActionTile extends StatelessWidget {
  const AgroActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.description,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    enabled: onTap != null,
    label: description == null ? label : '$label. $description',
    excludeSemantics: true,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(AgroSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: AgroSizes.iconAction,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AgroSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (description case final value?) ...[
                  const SizedBox(height: AgroSpacing.xxs),
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

final class AgroAdaptiveGrid extends StatelessWidget {
  const AgroAdaptiveGrid({
    required this.children,
    this.columns,
    this.uniformHeight = false,
    super.key,
  });

  final List<Widget> children;

  /// Fixed column count; when null the grid adapts to width and text scale.
  final int? columns;

  /// Gives every tile the height of the tallest one.
  final bool uniformHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(1);
      final columns =
          this.columns ??
          (constraints.maxWidth >= 360 && textScale <= 1.35 ? 2 : 1);
      final width = columns == 1
          ? constraints.maxWidth
          : (constraints.maxWidth - AgroSpacing.xs * (columns - 1)) / columns;
      if (uniformHeight) {
        return _UniformHeightGrid(
          columns: columns,
          spacing: AgroSpacing.xs,
          children: children,
        );
      }
      return Wrap(
        spacing: AgroSpacing.xs,
        runSpacing: AgroSpacing.xs,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

/// Grid whose cells all take the tallest cell's intrinsic height.
final class _UniformHeightGrid extends MultiChildRenderObjectWidget {
  const _UniformHeightGrid({
    required this.columns,
    required this.spacing,
    required super.children,
  });

  final int columns;
  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderUniformHeightGrid(columns: columns, spacing: spacing);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderUniformHeightGrid renderObject,
  ) {
    renderObject
      ..columns = columns
      ..spacing = spacing;
  }
}

final class _GridParentData extends ContainerBoxParentData<RenderBox> {}

final class _RenderUniformHeightGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridParentData> {
  _RenderUniformHeightGrid({required this._columns, required this._spacing});

  int _columns;
  set columns(int value) {
    if (value == _columns) return;
    _columns = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridParentData) {
      child.parentData = _GridParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final cellWidth = (width - _spacing * (_columns - 1)) / _columns;
    var cellHeight = 0.0;
    var child = firstChild;
    while (child != null) {
      final height = child.getMaxIntrinsicHeight(cellWidth);
      if (height > cellHeight) cellHeight = height;
      child = childAfter(child);
    }
    var index = 0;
    child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: cellWidth, height: cellHeight),
      );
      final column = index % _columns;
      final row = index ~/ _columns;
      (child.parentData! as _GridParentData).offset = Offset(
        column * (cellWidth + _spacing),
        row * (cellHeight + _spacing),
      );
      index++;
      child = childAfter(child);
    }
    final rows = (childCount + _columns - 1) ~/ _columns;
    size = constraints.constrain(
      Size(width, rows == 0 ? 0 : rows * cellHeight + (rows - 1) * _spacing),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
