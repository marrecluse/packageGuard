import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomContainer extends StatelessWidget {
  EdgeInsetsGeometry? margin;
  double? height;
  double? width;
  Decoration? decoration;
  Color? color;
  Widget? child;
  CustomContainer(
      {this.margin,
      this.height,
      this.width,
      this.decoration,
      this.color,
      this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: decoration,
      color: color,
      child: child,
    );
  }
}
