import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double sp(double designSize) {
    const designWidth = 390.0;
    return designSize * (screenWidth / designWidth).clamp(0.85, 1.15);
  }

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
}
