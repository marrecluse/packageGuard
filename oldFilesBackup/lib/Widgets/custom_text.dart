import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  String title;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;
  TextAlign? textAlign;
  TextDecoration? decoration;

  CustomText(
      {required this.title,
      this.fontSize,
      this.fontWeight,
      this.color,
      this.textAlign,
      this.decoration,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: textAlign,
      
      style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.7,
          color: color,
          fontFamily: 'Inter',
          decoration: decoration),
    );
  }
}
