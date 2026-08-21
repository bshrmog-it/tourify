import 'dart:ui';

import 'package:flutter/material.dart';

import '../const.dart';

final lightTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: Brightness.light,
  ).copyWith(primary: kPrimary, surface: kBackground, error: kRejected),

  scaffoldBackgroundColor: kBackground,

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black54),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
);
final darkTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: Brightness.dark,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
);
