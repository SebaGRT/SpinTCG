import 'package:flutter/material.dart';

const kBrand = 'SpinTCG';

abstract final class Court {
  static const c950 = Color(0xff072519);
  static const c900 = Color(0xff0a3324);
  static const c800 = Color(0xff0f4630);
  static const c700 = Color(0xff155c3f);
  static const c600 = Color(0xff1d7550);
  static const c200 = Color(0xffc9ddd0);
  static const c100 = Color(0xffe3eee7);
  static const c50 = Color(0xfff1f6f2);
  static const ball = Color(0xffdcf04a);
  static const ballDark = Color(0xffb7cc1c);
  static const paper = Color(0xfff6f7f2);
  static const ink = Color(0xff11201a);
  static const muted = Color(0xff5e6b64);
  static const line = Color(0xffdfe5df);
  static const loss = Color(0xffb4442f);

  static const disabled = Color(0xffe4e8e3);
  static const disabledText = Color(0xff8b958f);
  static const locked = Color(0xffeceee9);
  static const lockedInner = Color(0xffe1e5e0);
  static const segment = Color(0xffe9ece6);
}

TextStyle display(
  double size, {
  FontWeight weight = FontWeight.w800,
  Color? color,
  double height = 1.1,
}) => TextStyle(
  fontFamily: 'Archivo',
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: -0.02 * size,
);

TextStyle body(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
}) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Court.c800,
      primary: Court.c800,
      secondary: Court.ball,
      surface: Court.paper,
      error: Court.loss,
    ),
    scaffoldBackgroundColor: Court.paper,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Court.ink,
      displayColor: Court.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Court.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Court.paper,
      showDragHandle: true,
      dragHandleColor: Court.line,
    ),
  );
}
