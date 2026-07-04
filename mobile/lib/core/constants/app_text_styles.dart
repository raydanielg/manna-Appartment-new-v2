import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).textTheme.titleLarge?.color,
      );
  static TextStyle heading2(BuildContext context) => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.titleLarge?.color,
      );
  static TextStyle body(BuildContext context) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );
  static TextStyle caption(BuildContext context) => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );
}
