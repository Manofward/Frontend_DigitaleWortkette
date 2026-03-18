import 'package:flutter/material.dart';
import 'app_theme.dart';

class RanklistThemes{
  static final rankStyles = [
    AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
      color: Colors.amber[500],
    ),
    AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
      color: Colors.grey,
    ),
    AppTheme.lightTheme.textTheme.bodyLarge!.copyWith(
      color: Colors.brown,
    ),
  ];

  static final defaultStyle = AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
    color: Colors.black,
  );
}