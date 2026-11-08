import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppWidget {
  // ---------- TEXT STYLES ----------
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }

  /// White Bold Text
  static TextStyle WhiteBoldTextFieldStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }


  static TextStyle HeadlineTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle WhiteHeadlineTextFieldStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle LightTextFieldStyle() {
    return const TextStyle(
      color: Colors.black38,
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Courgette',
    );
  }

  static TextStyle WhiteLightTextFieldStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Courgette',
    );
  }

  static TextStyle semiTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle bodyTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );
  }

  static TextStyle semiCourgetteTextFieldStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 40.0,
      fontWeight: FontWeight.w500,
      fontFamily: 'Courgette',
    );
  }

  static TextStyle EmoticonCourgetteTextFieldStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 12.0,
      fontFamily: 'Poppins',
    );
  }

  // ---------- HELPERS ----------
  static String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// 🔥 Reusable Toast Helper
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
