import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../../Widgets/custom_text.dart';

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({super.key});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool status = true;
  String textStatus = 'Armed';
  String textStatusof = 'Disarmed';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomText(
          title: textStatus,
          color: textStatus == "Armed" ? const Color(0xff348D15) : Colors.red,
          fontSize: 13.sp,
        ),
        SizedBox(width: 5.w),
        FlutterSwitch(
          padding: 0,
          activeColor: const Color(0xff3FCE33),
          inactiveColor: Colors.red,
          value: status,
          width: 40,
          height: 20,
          toggleSize: 20,
          onToggle: (value) {
            setState(
              () {
                String temp = textStatus;
                textStatus = textStatusof;
                textStatusof = textStatus;
                textStatusof = temp;
                status = value;
              },
            );
          },
        ),
      ],
    );
    // Transform.scale(
    //   scale: 1,
    //   child: Switch(
    //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //     activeTrackColor: Color(0xff3FCE33),
    //     activeColor: Colors.white,
    //     inactiveTrackColor: Colors.red,
    //     value: true,
    //     onChanged: (value) {},
    //   ),
    // );
  }
}
