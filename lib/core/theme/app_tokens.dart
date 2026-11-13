import 'package:flutter/material.dart';

/// Spacing tokens on the 8pt grid. Use these instead of numeric literals.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner-radius tokens. One scale for the whole app.
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}

/// Shadow tokens. The clean-current direction is flat: no shadows anywhere
/// on the rebuilt screens. These are kept as transparent no-ops so existing
/// call sites keep compiling; new code must use hairline borders instead.
abstract final class AppShadows {
  static const card = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0),
    offset: Offset.zero,
    blurRadius: 0,
  );

  static const raised = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0),
    offset: Offset.zero,
    blurRadius: 0,
  );
}

/// Motion tokens. One authored entrance moment per screen at most;
/// press feedback is 200ms ease-out everywhere.
abstract final class AppMotion {
  static const press = Duration(milliseconds: 200);
  static const transition = Duration(milliseconds: 250);
  static const entrance = Duration(milliseconds: 300);
  static const curve = Curves.easeOut;
}

/// Minimum touch-target size (Apple HIG / Material).
abstract final class AppTargets {
  static const double min = 44;
}
