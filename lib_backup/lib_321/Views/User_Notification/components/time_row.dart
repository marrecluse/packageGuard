import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgets/custom_text.dart';

class TimeRow extends StatelessWidget {
  const TimeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          title: '9/26/23 at 10:35am',
          fontSize: 8.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xff4F4F4F),
        ),
        CustomText(
          title: 'at',
          fontSize: 8.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xff4F4F4F),
        ),
        CustomText(
          title: '10:35am',
          fontSize: 8.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xff4F4F4F),
        )
      ],
    );
  }
}
