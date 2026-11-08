import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.grey.shade800, // Darker for AppBar icons to contrast with inversePrimary
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade600, // Slightly darker for AppBar background
  ),
  scaffoldBackgroundColor: Colors.white, // Lighter for shadow contrast
  iconTheme: const IconThemeData(color: Colors.black), // Ensure Drawer icons are visible
);

/*
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade100,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade500,
  ),
  scaffoldBackgroundColor: Colors.grey.shade300,
);
* */