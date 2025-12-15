import 'package:flutter/material.dart';
import 'golden_ratio.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      primary: Colors.orange[900],
      secondary: Colors.limeAccent[700],
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
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: GoldenRatio.small,
        fontWeight: FontWeight.w300,
      ),
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
