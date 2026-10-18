import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class CropPictogram extends StatelessWidget {
  const CropPictogram({
    this.asset,
    this.colorToken,
    this.semanticLabel,
    this.apiary = false,
    super.key,
  });

  /// Apiary units always show a bee instead of a crop pictogram.
  static const apiaryIcon = Icons.emoji_nature;

  /// The catalog id of the beekeeping "crop".
  static const apiaryCropId = 'apicultura';

  final String? asset;
  final String? colorToken;
  final String? semanticLabel;
  final bool apiary;

  @override
  Widget build(BuildContext context) {
    final foreground = _color(context, colorToken);
    final image = apiary
        ? Icon(apiaryIcon, color: foreground, size: AgroSizes.iconFeatured)
        : asset == null
        ? Icon(LucideIcons.leaf, color: foreground)
        : SvgPicture.asset(
            asset!,
            width: AgroSizes.iconFeatured,
            height: AgroSizes.iconFeatured,
            placeholderBuilder: (_) =>
                Icon(LucideIcons.leaf, color: foreground),
            errorBuilder: (_, _, _) =>
                Icon(LucideIcons.leaf, color: foreground),
          );
    return Semantics(
      image: semanticLabel != null,
      label: semanticLabel,
      excludeSemantics: semanticLabel == null,
      child: Container(
        width: AgroSizes.cropPictogram,
        height: AgroSizes.cropPictogram,
        padding: const EdgeInsets.all(AgroSpacing.xs),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(AgroRadii.medium),
        ),
        child: image,
      ),
    );
  }

  static Color _color(BuildContext context, String? token) => switch (token) {
    'cropBerry' => AgroColors.rose,
    'cropCereal' => AgroColors.accent,
    'cropRoot' => AgroColors.amberDark,
    'cropApiary' => AgroColors.violet,
    'cropFruit' => AgroColors.sky,
    'cropVine' => AgroColors.violet,
    'cropOrchard' => AgroColors.brand,
    _ => Theme.of(context).colorScheme.primary,
  };
}
