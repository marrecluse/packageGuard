import 'package:flutter/material.dart';

import '../../../Widgets/custom_text.dart';

// ignore: must_be_immutable
class InnerContainerData extends StatelessWidget {
  String img;
  String toptext;
  String btnText;
  FontWeight? tFontWeight;
  FontWeight? bFontWeight;
  double? imgHeight;
  double? imgWidth;

  InnerContainerData({
    required this.img,
    required this.toptext,
    required this.btnText,
    this.tFontWeight,
    this.bFontWeight,
    this.imgHeight,
    this.imgWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          img,
          height: imgHeight,
          width: imgWidth,
        ),
        CustomText(
          title: toptext,
          fontSize: 7,
          fontWeight: tFontWeight,
          color: Color(0xff464646),
        ),
        CustomText(
          title: btnText,
          fontSize: 7,
          fontWeight: bFontWeight,
          color: Color(0xff464646),
        ),
      ],
    );
  }
}
