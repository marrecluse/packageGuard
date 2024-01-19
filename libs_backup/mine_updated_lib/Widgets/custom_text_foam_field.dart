import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../Utils/app_colors.dart';

class CustomTextFoamField extends StatefulWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  CustomTextFoamField({
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomTextFoamField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFoamField> {
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: context.screenHeight * 0.02,  // Adjust the vertical padding
          horizontal: context.screenWidth * 0.04,  // Adjust the horizontal padding
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: AppColors.grey,
          fontSize: context.screenWidth * 0.04,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    setState(() {
            obscureText = !obscureText;

                    });
                  });
                },
                child: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : widget.suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: AppColors.white,
            width: 5.0,
          ),
        ),
      ),
      style: TextStyle(
        fontSize: context.screenWidth * 0.04,
      ),
      validator: widget.validator,
    );
  }
}




















// class CustomTextFoamField extends StatelessWidget {
//   String? hintText;
//   Widget? prefixIcon;
//   Widget? suffixIcon;
//   bool obscureText;
//   final TextEditingController controller;
//   String? Function(String?)? validator;
//   CustomTextFoamField(
//       {this.hintText,
//       this.prefixIcon,
//       this.suffixIcon,
//       this.validator,
//       this.obscureText = false, // Added the obscureText property
//       required this.controller,
//       super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//   controller: controller,
//   obscureText: obscureText,
//   decoration: InputDecoration(
//     contentPadding: EdgeInsets.symmetric(
//     vertical: context.screenWidth * 0.02,  // Adjust the vertical padding
//     horizontal: context.screenWidth * 0.04,  // Adjust the horizontal padding
//     ),
//     hintText: hintText,
//     hintStyle: TextStyle(
//     color: AppColors.grey,
//     fontSize: context.screenWidth * 0.04,
//     ),
//     prefixIcon: prefixIcon,
//     suffixIcon: obscureText
//     ? GestureDetector(
//       onTap: () {
//         // Toggle the password visibility when tapped
        
//         obscureText = !obscureText;
//       },
//       child: Icon(
//         obscureText ? Icons.visibility : Icons.visibility_off,
//       ),
//     )
//     : suffixIcon,
//     border: OutlineInputBorder(
//     // borderRadius: BorderRadius.circular(4.0),
//     // borderSide: BorderSide(
//     //   color: AppColors.white,
//     //   width: 5.0,
//     // ),
//     ),
//   ),
//   style: TextStyle(
//     fontSize: context.screenWidth * 0.04,
//   ),
//   validator: validator,
// );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../Utils/app_colors.dart';

// // ignore: must_be_immutable
// class CustomTextFoamField extends StatelessWidget {
//   String? hintText;
//   Widget? prefixIcon;
//   Widget? suffixIcon;
//   String? Function(String?)? validator;
//   CustomTextFoamField(
//       {this.hintText,
//       this.prefixIcon,
//       this.suffixIcon,
//       this.validator,
//       super.key});


//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 355.w,
//       height: 47.h,
//       decoration: ShapeDecoration(
//         color: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4).r),

//         shadows: [
//           BoxShadow(
//             color: const Color(0x3F000000),
//             blurRadius: 5.r,
//             offset: const Offset(0, 0),
//             spreadRadius: 0,
//           )
//         ],
//       ),
//       child: TextFormField(
        
//         decoration: InputDecoration(
//           // contentPadding: EdgeInsets.only(left: 12.w, right: 10.w,bottom: 5.w,),
//           // contentPadding: EdgeInsets.only(left: 12),
//           contentPadding: EdgeInsets.all(15.h),
//           hintText: hintText,
//           hintStyle: TextStyle(

//             color: AppColors.grey, fontSize: 16.sp),

//           prefixIcon: prefixIcon,
//           suffixIcon: suffixIcon,
//           border: InputBorder.none,
//         ),
//         style: TextStyle(
//           fontSize: 15.w,
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }
