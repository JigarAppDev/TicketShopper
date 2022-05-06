import 'package:flutter/material.dart';
import 'package:ticket_stopper/Constant.dart';

class DefaultText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  const DefaultText({this.text, this.fontSize: 20, this.color: kPrimaryColor2, this.fontWeight: FontWeight.bold});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  AppText({this.text, this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontFamily: 'Poppins', fontSize: fontSize),
    );
  }
}
