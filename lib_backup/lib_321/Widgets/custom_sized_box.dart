import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSizeBox extends StatelessWidget {
  double? width;
  double? height;
  Widget? child;
  CustomSizeBox({this.width, this.height, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
