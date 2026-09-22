import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  TextStyle get titleLarge => GoogleFonts.getFont('Inter', color: primaryText, fontWeight: FontWeight.w600, fontSize: 22);
  TextStyle get titleMedium => GoogleFonts.getFont('Inter', color: info, fontWeight: FontWeight.normal, fontSize: 18);
  TextStyle get titleSmall => GoogleFonts.getFont('Inter', color: info, fontWeight: FontWeight.w500, fontSize: 16);
  TextStyle get labelLarge => GoogleFonts.getFont('Inter', color: secondaryText, fontWeight: FontWeight.normal, fontSize: 16);
  TextStyle get labelMedium => GoogleFonts.getFont('Inter', color: secondaryText, fontWeight: FontWeight.normal, fontSize: 14);
  TextStyle get labelSmall => GoogleFonts.getFont('Inter', color: secondaryText, fontWeight: FontWeight.normal, fontSize: 12);
  TextStyle get bodyLarge => GoogleFonts.getFont('Inter', color: primaryText, fontWeight: FontWeight.normal, fontSize: 16);
  TextStyle get bodyMedium => GoogleFonts.getFont('Inter', color: primaryText, fontWeight: FontWeight.normal, fontSize: 14);
  TextStyle get bodySmall => GoogleFonts.getFont('Inter', color: primaryText, fontWeight: FontWeight.normal, fontSize: 12);
}

class LightModeTheme extends FlutterFlowTheme {
  late Color primary = const Color(0xFF4B39EF);
  late Color secondary = const Color(0xFF39D2C0);
  late Color tertiary = const Color(0xFFEE8B60);
  late Color alternate = const Color(0xFFE0E3E7);
  late Color primaryText = const Color(0xFF14181B);
  late Color secondaryText = const Color(0xFF57636C);
  late Color primaryBackground = const Color(0xFFF1F4F8);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0x4C4B39EF);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0x4DEE8B60);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF249689);
  late Color warning = const Color(0xFFF9CF58);
  late Color error = const Color(0xFFFF5963);
  late Color info = const Color(0xFFFFFFFF);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily ?? 'Inter',
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              decoration: decoration ?? this.decoration,
              height: lineHeight ?? height,
              shadows: shadows ?? this.shadows,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              letterSpacing: letterSpacing,
              fontWeight: fontWeight,
              fontStyle: fontStyle,
              decoration: decoration,
              height: lineHeight,
              shadows: shadows,
            );
}
