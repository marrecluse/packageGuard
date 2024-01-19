import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  String title;
    int lines;

  double? fontSize;
  FontWeight? fontWeight;
  Color? color;
  TextAlign? textAlign;
  TextDecoration? decoration;
  

  CustomText(
      {required this.title,
      this.fontSize,
      this.lines=1,
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
      softWrap: true,
      maxLines: lines,
      style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.7,
          color: color,

        
          decoration: decoration),
    );
  }
}

class CustomText2 extends StatelessWidget {
  List title;
  double? fontSize;
  FontWeight? fontWeight;
  Color? color;
  TextAlign? textAlign;
  TextDecoration? decoration;

  CustomText2(
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
      
      title as String,
      textAlign: textAlign,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
                  fontFamily: 'Montserrat',

          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.7,
          color: color,
          
          
          decoration: decoration),
    );
  }
}
