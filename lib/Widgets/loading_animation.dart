import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/theme/app_theme.dart';

class LoadingAnimation {
  static loadingAnimation() {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: AppTheme.lightTheme.colorScheme.secondary,
        size: 70
      ),
    );
  }
}