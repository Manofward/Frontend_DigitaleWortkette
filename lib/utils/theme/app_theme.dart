import 'package:flutter/material.dart';
import 'golden_ratio.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      primary: Colors.orange[900],
      secondary: Colors.blueAccent[400],
    ),

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: GoldenRatio.h1,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: GoldenRatio.h2,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: GoldenRatio.body,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontSize: GoldenRatio.medium,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontSize: GoldenRatio.small,
        fontWeight: FontWeight.w500,
      )
    ),
    /* appBar Theming
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: GoldenRatio.h2,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    */
  );
}
