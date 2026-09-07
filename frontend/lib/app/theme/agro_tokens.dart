import 'package:flutter/material.dart';

abstract final class AgroColors {
  static const brand = Color(0xFF2A6E54);
  static const brandDark = Color(0xFF1F4B3A);
  static const brandSoft = Color(0xFFBFE1D0);
  static const accent = Color(0xFFEDB240);
  static const accentSoft = Color(0xFFF6E4B7);
  static const ink = Color(0xFF17372B);
  static const muted = Color(0xFF587267);
  static const line = Color(0xFFB7DCCB);
  static const surface = Color(0xFFFFFFFF);
  static const greenSoft = Color(0xFFDDF4EA);
  static const sky = Color(0xFF2563EB);
  static const skyDark = Color(0xFF1D4ED8);
  static const skySoft = Color(0xFFDBEAFE);
  static const rose = Color(0xFFB9435B);
  static const roseDark = Color(0xFF7C1F2D);
  static const roseSoft = Color(0xFFFFE0E6);
  static const amberDark = Color(0xFF92400E);
  static const amberSoft = Color(0xFFFFF1C7);
  static const violet = Color(0xFF6657A6);
  static const violetSoft = Color(0xFFE8E4FF);
  static const mapCanvas = Color(0xFFEEF2E8);
  static const mapPolygonActive = Color(0x884B7F52);
  static const mapPolygonSaved = Color(0x554B7F52);
  static const mapPolygonStroke = Color(0xFF2F6338);
  static const mapOverlayShadow = Color(0x33000000);
}

abstract final class AgroSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AgroRadii {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 22.0;
  static const hero = 24.0;
  static const full = 999.0;
}

abstract final class AgroSizes {
  static const touchTarget = 48.0;
  static const iconAuxiliary = 16.0;
  static const iconStandard = 20.0;
  static const iconAction = 24.0;
  static const iconFeatured = 32.0;
  static const cropPictogram = 48.0;
  static const sectorSelectorRow = 56.0;
  static const globalStatus = 48.0;
  static const mapPreview = 184.0;
  static const maxContentWidth = 840.0;
  static const mapVertexVisual = 20.0;
}

abstract final class AgroElevation {
  static const card = 1.0;
  static const floating = 3.0;
}

abstract final class AgroMotion {
  static const quick = Duration(milliseconds: 100);
  static const standard = Duration(milliseconds: 200);
  static const emphasized = Duration(milliseconds: 300);
}

@immutable
final class AgroSemanticColors extends ThemeExtension<AgroSemanticColors> {
  const AgroSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.error,
    required this.onError,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color error;
  final Color onError;

  @override
  AgroSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? error,
    Color? onError,
  }) => AgroSemanticColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
    error: error ?? this.error,
    onError: onError ?? this.onError,
  );

  @override
  AgroSemanticColors lerp(covariant AgroSemanticColors? other, double t) =>
      other == null
      ? this
      : AgroSemanticColors(
          success: Color.lerp(success, other.success, t)!,
          onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
          warning: Color.lerp(warning, other.warning, t)!,
          onWarning: Color.lerp(onWarning, other.onWarning, t)!,
          info: Color.lerp(info, other.info, t)!,
          onInfo: Color.lerp(onInfo, other.onInfo, t)!,
          error: Color.lerp(error, other.error, t)!,
          onError: Color.lerp(onError, other.onError, t)!,
        );
}
