import 'package:flutter/material.dart';

class MyColors {

  static const MaterialColor meteblue = MaterialColor(
      _metebluePrimaryValue, <int, Color>{
    50: Color(0xFFF1F5FC),
    100: Color(0xFFDCE6F7),
    200: Color(0xFFC5D5F2),
    300: Color(0xFFADC4ED),
    400: Color(0xFF9CB7E9),
    500: Color(_metebluePrimaryValue),
    600: Color(0xFF82A3E2),
    700: Color(0xFF7799DE),
    800: Color(0xFF6D90DA),
    900: Color(0xFF5A7FD3),
  });
  static const int _metebluePrimaryValue = 0xFF8AAAE5;

  static const MaterialColor meteblueAccent = MaterialColor(
      _meteblueAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_meteblueAccentValue),
    400: Color(0xFFD4E1FF),
    700: Color(0xFFBACFFF),
  });
  static const int _meteblueAccentValue = 0xFFFFFFFF;

}