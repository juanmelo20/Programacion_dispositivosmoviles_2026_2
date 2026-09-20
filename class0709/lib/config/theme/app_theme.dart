import 'package:flutter/material.dart';
const colorList = <Color>[
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.cyan,
  Colors.lime,
];
class AppTheme {
  ThemeData themeData() {
    return ThemeData(
      colorSchemeSeed: colorList[6],
      appBarTheme: AppBarTheme(
        backgroundColor: colorList[6],
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.normal,
        ),
      ),
      brightness: Brightness.light,
    );
  }
}