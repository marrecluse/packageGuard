// Column(
//                       children: [
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             CustomText(
//                                 title: 'Name',
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.navyblue),
        
//                             CustomSizeBox(
//                               width: 15.w,
//                             ),
        
//                             Container(
//                               width: 225.w,
//                               height: 35.h,
//                               decoration: ShapeDecoration(
//                                 color: AppColors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4).r),
//                                 shadows: [
//                                   BoxShadow(
//                                     color: const Color(0x3F000000),
//                                     blurRadius: 5.r,
//                                     offset: const Offset(0, 0),
//                                     spreadRadius: 0,
//                                   )
//                                 ],
//                               ),
//                               child: Expanded(
//                                 child: 
//                                 TextFormField(
//                                   controller: emailController,
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.only(
//                                         left: 2.w, bottom: 20.h, right: 10.w),
//                                     hintText: 'Email',
//                                     hintStyle: TextStyle(
//                                         color: AppColors.grey, fontSize: 13.sp),
//                                     border: InputBorder.none,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             //   Expanded(child:
//                             // //  CustomTextFoamField()
//                             //   ),
//                           ],
//                         ),
//                         CustomSizeBox(height: 10.w),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             CustomText(
//                                 title: 'Phone',
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.navyblue),
//                             CustomSizeBox(
//                               width: 15.w,
//                             ),
        
//                             Container(
//                               width: 225.w,
//                               height: 35.h,
//                               decoration: ShapeDecoration(
//                                 color: AppColors.white,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(4).r),
//                                 shadows: [
//                                   BoxShadow(
//                                     color: const Color(0x3F000000),
//                                     blurRadius: 5.r,
//                                     offset: const Offset(0, 0),
//                                     spreadRadius: 0,
//                                   )
//                                 ],
//                               ),
//                               child: TextFormField(
//                                 controller: phoneController,
//                                 decoration: InputDecoration(
//                                   contentPadding: EdgeInsets.only(
//                                       left: 2.w, bottom: 20.h, right: 10.w),
//                                   hintText: 'Phone',
//                                   hintStyle: TextStyle(
//                                       color: AppColors.grey, fontSize: 13.sp),
//                                   border: InputBorder.none,
//                                 ),
//                               ),
//                             )
//                             // Expanded(child: CustomTextFoamField()),
//                           ],
//                         ),
//                         CustomSizeBox(height: 10.w),
//                         Row(
//                           children: [
//                             imageFile == null
//                                 ? GestureDetector(
//                                     onTap: () {
//                                       showOptionsDialog(context);
//                                     },
//                                     child: CustomText(
//                                         title: 'Choose Photo',
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.w700,
//                                         color: AppColors.navyblue),
//                                   )
//                                 : Container(
//                                     height: 50.h,
//                                     width: 50.w,
//                                     child: Image.file(
//                                       File(imageFile!.path),
//                                       fit: BoxFit.fill,
//                                     ),
//                                   ),
//                             CustomSizeBox(width: 40.w),
//                             GestureDetector(
//                               onTap: () {
//                                 AppConstants.showCustomSnackBar(
//                                     "Image uploaded");
//                               },
//                               child: Container(
//                                 height: 35.h,
//                                 width: 80.w,
//                                 decoration: BoxDecoration(
//                                     color: AppColors.navyblue,
//                                     borderRadius: BorderRadius.circular(5.r)),
//                                 child: Center(
//                                   child: CustomText(
//                                     title: "Upload",
//                                     fontSize: 13.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: AppColors.btntext,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Align(
//                           alignment: Alignment.topRight,
//                           child: GestureDetector(
//                             onTap: () async {
//                               sendMail(
//                     recipientEmail: emailController.text.toString(),
//                     mailMessage: 'Welcome to safe circle'.toString(),
//                   );
                               
                             
//                               if (emailController.text.isNotEmpty &&
//                                   phoneController.text.isNotEmpty) {
//                                 // Add data to Firestore
//                                 await addSafePersonToFirestore(
//                                     emailController.text, phoneController.text);
//                                       await addSafePersonToFirestore(emailController.text, phoneController.text);

//             // // Send an email
//             // await sendEmail(
//             //   'safe package',
//             //   'Your are add in safe circle',
//             //   emailController.text,
//             // );
        
//                                 // Show a snackbar
//                                 AppConstants.showCustomSnackBar(
//                                     "Safe Circle Person added!");
        
//                                 // Navigate to the EditSafeCircle page
//                                 Get.to(() => EditSafeCircle());
//                               } else {
//                                 // Handle the case where email or phone is empty
//                                 AppConstants.showCustomSnackBar(
//                                     "Please fill in both email and phone.");
//                               }
//                             },
//                             child: Container(
//                               height: 30.h,
//                               width: 80.w,
//                               decoration: BoxDecoration(
//                                   color: AppColors.green,
//                                   borderRadius: BorderRadius.circular(8.r)),
//                               child: Center(
//                                 child: CustomText(
//                                   title: "Add",
//                                   fontSize: 13.sp,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppColors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),