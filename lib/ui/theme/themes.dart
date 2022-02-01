import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  /// Typically, only the [brightness], [primaryColor], or [primarySwatch] are
  /// specified. That pair of values are used to construct the [colorScheme].
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  primarySwatch: Colors.blue,
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
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(color: Colors.grey.shade700, width: 0.1),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700, width: 0.1),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700, width: 0.1),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade500, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade500, width: 1.0),
    ),
    contentPadding: const EdgeInsets.all(5.0),
  ),

  // -- ELEVATED BUTTON --
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        color: Colors.white,
      ),
      elevation: 0.0,
    ),
  ),

  // -- TEXT THEME --
  /// If you specify textTheme in ThemeData() constructor, ThemeData merges it
  /// with defaultTextTheme
  textTheme: const TextTheme(
    bodyText1: TextStyle(fontSize: 16.0), // Material spec 16.0
    bodyText2: TextStyle(fontSize: 16.0), // Material spec 14.0
    caption: TextStyle(fontSize: 15.0),
  ),
);
