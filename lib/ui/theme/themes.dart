import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  /// Typically, only the [brightness], [primaryColor], or [primarySwatch] are
  /// specified. That pair of values are used to construct the [colorScheme].
  brightness: Brightness.light,
  primaryColor: Colors.lightBlue,
  primarySwatch: Colors.lightBlue,
  canvasColor: Colors.white,

  // -- FONT --
  /// Use default font(San Francisco). Android(Roboto) iOS(San Francisco)

  // -- SCAFFOLD --
  /// scaffoldBackgroundColor: When null, default value is canvasColor.

  // -- APP BAR --
  /// All AppBarTheme properties are null by default. When null, the AppBar
  /// compute its own default values, typically based on the overall theme's
  /// ThemeData.colorScheme, ThemeData.textTheme, and ThemeData.iconTheme.
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),

  // -- BOTTOM NAVIGATION BAR --
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
  ),

  // -- BOTTOM SHEET --
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
  ),

  // -- INPUT DECORATION --
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.5),
    ),
    contentPadding: const EdgeInsets.all(5.0),
  ),
);
