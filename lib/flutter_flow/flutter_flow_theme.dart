import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) => FlutterFlowTheme();

  Color get primary => const Color(0xFF4B39EF);
  Color get secondary => const Color(0xFF39D2C0);
  Color get tertiary => const Color(0xFFEE8B60);
  Color get alternate => const Color(0xFFE0E3E7);
  Color get primaryText => const Color(0xFF14181B);
  Color get secondaryText => const Color(0xFF57636C);
  Color get primaryBackground => const Color(0xFFF1F4F8);
  Color get secondaryBackground => const Color(0xFFFFFFFF);

  TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500);
  TextStyle get titleLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w500);
  TextStyle get titleMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500);
  TextStyle get titleSmall => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500);
  TextStyle get labelLarge => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal);
  TextStyle get labelMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal);
  TextStyle get labelSmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal);
  TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal);
  TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal);
  TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal);
}

extension TextStyleExt on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    double? lineHeight,
    Paint? foreground,
    Color? backgroundColor,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) {
    return copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: lineHeight,
      foreground: foreground,
      backgroundColor: backgroundColor,
      shadows: shadows,
      decoration: decoration,
    );
  }
}
