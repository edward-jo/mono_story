import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  /// Typically, only the [brightness], [primaryColor], or [primarySwatch] are
  /// specified. That pair of values are used to construct the [colorScheme].
  brightness: Brightness.light,
  primaryColor: Colors.white,
  primarySwatch: Colors.blueGrey,
  canvasColor: Colors.white,
  fontFamily: GoogleFonts.openSans().fontFamily,

  /// -- SCAFFOLD --
  /// scaffoldBackgroundColor: When null, default value is canvasColor.

  /// -- APP BAR --
  /// All AppBarTheme properties are null by default. When null, the AppBar
  /// compute its own default values, typically based on the overall theme's
  /// ThemeData.colorScheme, ThemeData.textTheme, and ThemeData.iconTheme.
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
);
