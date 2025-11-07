// TEXT STYLE
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class CustomColor {
  static const primary = Color(0xFFF4B666);
  static const surface = Color(0xFFFAF8F1);
  static const buttonColor = Color(0xFFC58940);
  static const dateBackground = Color(0xFFED9D3B);
  static const borderColor = Color(0xFF979797);
  static Color backgroundColor = const Color(0xFFFAF8F1);

  static Color primaryColor50 = const Color(0xfffef8f0);
  static Color primaryColor100 = const Color(0xFFfce8d0);
  static Color primaryColor200 = const Color(0xFFfaddb9);
  static Color primaryColor300 = const Color(0xFFf8ce98);
  static Color primaryColor400 = const Color(0xFFf4b666);
  static Color primaryColor500 = const Color(0xFFF4B666);
  static Color primaryColor600 = const Color(0xFFdea65d);
  static Color primaryColor700 = const Color(0xFFad8148);
  static Color primaryColor800 = const Color(0xFF866438);
  static Color primaryColor900 = const Color(0xFF664c2b);

  static Color whiteColor = const Color(0xFFFFFFFF);
  static Color blackColor = const Color(0xFF343434);

  static Color subtitleTextColor = const Color(0xFF808080);
  static Color hintTextColor = const Color(0xFFBAC2C7);
  static Color warningColor = const Color(0xFFff3f56);

  static Color greyBackgroundColor = const Color(0xFFF9F9F9);

  static Color disabledColor = const Color(0xFFC4C4C4);
  static Color transparentColor = Colors.transparent;
}

TextStyle primaryTextStyle = GoogleFonts.poppins(
  color: CustomColor.blackColor,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;
