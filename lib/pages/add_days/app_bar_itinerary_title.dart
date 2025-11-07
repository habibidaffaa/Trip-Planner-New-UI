import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class AppBarItineraryTitle extends StatelessWidget {
  final String title;
  AppBarItineraryTitle({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: primaryTextStyle.copyWith(
        fontWeight: semibold,
        fontSize: 18,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
