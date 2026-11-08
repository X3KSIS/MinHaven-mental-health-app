import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade300, // Lighter for AppBar icons to contrast with inversePrimary
    secondary: const Color.fromARGB(255, 39, 39, 39),
    tertiary: const Color.fromARGB(255, 39, 39, 39),
    inversePrimary: Colors.grey.shade300,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,
  iconTheme: const IconThemeData(color: Colors.white), // Ensure Drawer icons are visible
);

/*
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade500,
    secondary: const Color.fromARGB(255, 39, 39, 39),
    tertiary: const Color.fromARGB(255, 39, 39, 39),
    inversePrimary: Colors.grey.shade300,
  ),
  scaffoldBackgroundColor: Colors.grey.shade900,
);
 */