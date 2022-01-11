import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  /// Typically, only the [brightness], [primaryColor], or [primarySwatch] are
  /// specified. That pair of values are used to construct the [colorScheme].
  brightness: Brightness.light,
  primaryColor: Colors.blueGrey,
  primarySwatch: Colors.blueGrey,
  canvasColor: Colors.white,

  /// -- FONT --
  /// Use default font(San Francisco). Android(Roboto) iOS(San Francisco)

  /// -- BOTTOM NAVIGATION BAR --
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
    selectedItemColor: Colors.black,
  ),

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
