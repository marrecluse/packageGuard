// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:packageguard/Utils/app_colors.dart';
import 'package:packageguard/Utils/app_images.dart';
import 'package:packageguard/Widgets/custom_appbar.dart';
import 'package:packageguard/firebase_options.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../Utils/app_constants.dart';
import '../../Widgets/custom_sized_box.dart';
import '../../Widgets/custom_text.dart';
import '../../Widgets/custom_text_foam_field.dart';
import '../../Widgets/drawer.dart';
import '../AddPackageGuard/add_packgard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../EditSafeCircle/edit_safecircle.dart';
import '../Login/login.dart';

String? mtoken = " ";

class ReceiverIdController extends GetxController {
  RxString receiverId = ''.obs;

  void updateData(String newData) {
    receiverId.value = newData;
  }
}

class AddSafePerson extends StatefulWidget {
  const AddSafePerson({super.key});

  @override
  State<AddSafePerson> createState() => _AddSafePersonState();
}

class _AddSafePersonState extends State<AddSafePerson> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final ReceiverIdController receiverIdController = Get.put(ReceiverIdController());

  String? mtoken = "";
  String? device_token = "";

  File? imageFile;
  String userId = '';
  String receiverUserId = '';

  final userController = Get.find<UserController>();

// Access user data
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    FirebaseMessaging.instance.subscribeToTopic("Animal");

    // requestPermission();
    // Access user data in initState or another method
    userData = userController.userData as Map<String, dynamic>;
  }

  Future<bool> checkIfExists(String inputEmail) async {
    bool check = false;

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      querySnapshot.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final email = data['Email'] as String?;

        if (inputEmail == email) {
          check = true;
        }
      });
    } catch (e) {
      print('Error checking if email exists: $e');
    }
    return check;
  }

  void getTokenFromFirestore() async {}

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
      'token': token,
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });

      saveToken(token!);
    });
  }

//   String getCurrentUserId() {

//   User? user = FirebaseAuth.instance.currentUser;
//   if (user != null) {
//     return user.uid;
//   } else {
//     // Handle the case when there is no signed-in user.
//     return 'No user signed in';
//   }
// }
// print(getCurrentUserId().toString());

  Future<String> getReceiverUserId(String userEmail) async {
    String titleText =
        '${nameController.text.toString()}! has been added to your Safe Circle';
    String titleText2 =
        'You have added ${nameController.text.toString()} to your Safe Circle';
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: userEmail)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      receiverUserId = doc.id;
      receiverIdController.updateData(receiverUserId);
      print('circle USER ID : $receiverUserId');
      // saveUserNotificationToFirestore(emailController.text.toString(),
      //     nameController.text.toString(), titleText);
      saveCircleNotificationToFirestore(
          emailController.text.toString(),
          nameController.text.toString(),
          titleText2,
          receiverUserId,
          userData['uid']);
      await SavaSenderIdToFireStore(receiverUserId);
      // Use 'await' here if needed
    }

    return receiverUserId;
  }

  void saveUserNotificationToFirestore(
      String userEmail, String userName, String titleText) async {
    //Get userID of the current user
    User? user = FirebaseAuth.instance.currentUser;
    print('USER DATA: ${user}');
    print('USER ID: ${user?.uid}');

    //Get userID of the receiver
    // getReceiverUserId(userEmail);

    final notificationData = {
      // 'Device Token': device_token, // Add the device token field
      'userEmail': userEmail, // Add user's email
      'name': userName, // Add user's email
      'notification': titleText, // Add the email from the input field
      "timestamp": Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user?.uid)
        .collection("userNotification")
        .add(notificationData);
  }

  SavaSenderIdToFireStore(String receiverId) async {
    User? user = await FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('status')
        .doc(receiverId)
        .set({userId: user});
    print('REciever ID is ${receiverId}');
  }

  void saveCircleNotificationToFirestore(String userEmail, String userName,
      String notification, String receiverId, String senderId) async {
    print('receiver id is:${receiverId}');
    // String receiveId = await getReceiverUserId(userEmail);
    var email;
    User? user = await FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('status')
        .doc(receiverId)
        .collection('notifications')
        .doc(notification)
        .set({'acceptStatus': false});

    // DocumentSnapshot<Map<String, dynamic>> recieverStatus =
    //     await FirebaseFirestore.instance
    //         .collection('status')
    //         .doc(receiverId)
    //         .collection('notifications')
    //         .doc(notification)
    //         .get();
    // print('receiver accept is:');
    // print(recieverStatus['accept']);

    // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('notifications')
    //     .doc(user?.uid)
    //     .collection('safeCircleNotification')
    //     .get();

    // querySnapshot.docs.forEach((doc) async {
    //   final data = doc.data() as Map<String, dynamic>;

    //   email = data['userEmail'] as String?;
    print('RECIEPENT EMAIL: ${userEmail}');
    print('DB EMAIL: ${email}');
    // });
    // if (userEmail != email) {
    // print('reciver userId: ${receiveId}');

    String notificationText =
        'You have added ${nameController.text.toString()} to your Safe Circle';
    String notificationText2 =
        'You have been added to ${userData['Name']} safe circle for package protection';
    final notificationData = {
      // 'Device Token': device_token, // Add the device token field
      'userEmail': userEmail, // Add user's email
      'name': userName,
      'userId': receiverUserId.toString(),
      'notification': notificationText2, // Add the email from the input field
      "timestamp": Timestamp.now(),
      "senderId": senderId
    };

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(user?.uid)
        .collection("safeCircleNotification")
        .add(notificationData);
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(receiverUserId)
        .collection("safeCircleNotification")
        .add(notificationData);
  }

Future<String> getTargetDeviceToken(String targetEmail) async{
  String targetToken='';
  try {
     DocumentSnapshot snap =
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(receiverUserId)
                                          .get();

                                  targetToken = snap['deviceToken'];
                                  print("target token is");
                                  print(targetToken);

  } catch (e) {
    print(e);
  }
return targetToken;

}




  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA7uEFuE0:APA91bGrr2KX44UfRmYqbVpU5YCv7KIwJWi1cRxiq0dF7sMv2N5yT6paJTHXhdH9xUc7gd02Yhaa76TlsZmCLI1CQAxtBDkw2ylEKC6i6rPqdqaiy-OdJkFVhsYSShDmRfNXJ45pi8mq',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,

              'icon':
                  'https://firebasestorage.googleapis.com/v0/b/packageguard-d517e.appspot.com/o/app_logo%2Fic_launcher.png?alt=media&token=aa85c460-d622-4243-8ca0-bf9d81ed683f' // This should point to the icon image
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
            // 'to': 'vKcfGYBymuNngtOmoAf4tPpGNyd2',
          },
        ),
      );
      print("here i am");
    } catch (e) {
      print("error push notification");
    }
  }


  void sendPushMessageToTarget(String targetToken,String receiverName) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAA7uEFuE0:APA91bGrr2KX44UfRmYqbVpU5YCv7KIwJWi1cRxiq0dF7sMv2N5yT6paJTHXhdH9xUc7gd02Yhaa76TlsZmCLI1CQAxtBDkw2ylEKC6i6rPqdqaiy-OdJkFVhsYSShDmRfNXJ45pi8mq',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': 'PackageGuard',
              'body': '$receiverName wants to add you in his safe circle',

              'icon':
                  'https://firebasestorage.googleapis.com/v0/b/packageguard-d517e.appspot.com/o/app_logo%2Fic_launcher.png?alt=media&token=aa85c460-d622-4243-8ca0-bf9d81ed683f' // This should point to the icon image
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': targetToken,
            // 'to': 'vKcfGYBymuNngtOmoAf4tPpGNyd2',
          },
        ),
      );
      print("here i am");
    } catch (e) {
      print("error push notification");
    }
  }




  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = 'danijakhar11@gmail.com';
    // change your password here
    String password = 'wxlthhhlaljgojjb';
    final smtpServer = gmail(username, password);
    final mailmessage = mailer.Message()
      ..from = Address(username, 'Mail Service')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(mailmessage, smtpServer);
      AppConstants.showCustomSnackBar('Email Sent Successfully');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addPerson({
    required String recipientEmail,
  }) async {
    var email;
    User? user = await FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('safeCircle')
        .doc(user?.uid)
        .collection('circlePersons')
        .get();

    querySnapshot.docs.forEach((doc) async {
      final data = doc.data() as Map<String, dynamic>;

      email = data['userEmail'] as String?;
      print('RECIEPENT EMAIL: ${recipientEmail}');
      print('FB EMAIL: ${email}');
    });
    if (recipientEmail != email) {
      await addSafePersonToFirestore(recipientEmail, nameController.text);
    } else {
      AppConstants.showCustomSnackBar("Already added to safe circle.");
    }

    // Add data to Firestore

    // Show a snackbar

    // Navigate to the EditSafeCircle page
    Get.to(() => EditSafeCircle());
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FittedBox(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  getFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    setState(() {});
  }

  getFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);

      print('IMAGW : $imageFile');
    }
    setState(() {});
  }

  Future<void> addSafePersonToFirestore(String addedEmail, String name) async {
    FirebaseMessaging.instance.getToken().then((fcmToken) {
      print("FCM Token: $fcmToken");
      setState(() {
        device_token = fcmToken;
      });
    });

    String imageUrl = ''; // Initialize imageUrl with an empty string
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final adminEmail = addedEmail; // Get the user's email
        if (imageFile != null) {
          imageUrl = (await uploadImageToFirebaseStorage(imageFile!))!;
        }
        if (adminEmail != null) {
          final safeCircleData = {
            // 'Device Token': device_token, // Add the device token field
            'userEmail': adminEmail, // Add user's email
            'deviceToken': device_token, // Add user's email
            'userName': name, // Add the email from the input field
            'image': imageUrl,
            'acceptStatus': false
          };
          print('Device Token$mtoken');
          print('User email$device_token ');

          final firestore = FirebaseFirestore.instance;
          // await firestore.collection('safeCircle').add(safeCircleData);
          await firestore
              .collection('safeCircle')
              .doc(user?.uid)
              .collection('circlePersons')
              .doc(receiverUserId)
              .set(safeCircleData);
          AppConstants.showCustomSnackBar("Safe Circle request sent");
        } else {
          AppConstants.showCustomSnackBar("Failed to get admin's email");
        }
      } else {
        AppConstants.showCustomSnackBar("User not logged in");
      }
    } catch (e) {
      print('Error adding data to Firestore: $e');
      AppConstants.showCustomSnackBar("Error adding data to Firestore");
    }
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('SafeCircle_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = userData['ProfileImage'].toString().trim();
    return SafeArea(
        child: Scaffold(
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              image: profileImage,
              title: '${userData['Name']}',
            ),
            Container(
              width: 358.w,
              //  height: 336.h,
              decoration: ShapeDecoration(
                color: const Color(0x2B15508D),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1.w, color: const Color(0x7F15508D)),
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title: 'Safe Circle',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyblue,
                    ),
                    CustomSizeBox(height: 20.h),
                    Row(
                      children: [
                        CustomSizeBox(width: 20.w),
                        Image.asset(
                          AppImages.vector,
                          height: 120.h,
                        ),
                        CustomText(
                          title:
                              'Join your neighbor’s Safe Circle\nand have them join yours. The\nwhole street then becomes\npackage guardians.',
                          fontSize: 10.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        )
                      ],
                    ),
                    CustomSizeBox(
                      height: 15.h,
                    ),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                                title: 'Name',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyblue),

                            CustomSizeBox(
                              width: 13.w,
                            ),

                            // 5.widthBox,
                            Container(
                              width: 225.w,
                              height: 45.h,
                              decoration: ShapeDecoration(
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius: BorderRadius.circular(4).r),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        bottom: 10.0, left: 10.0, top: 5),
                                    hintText: 'Name',
                                    hintStyle: TextStyle(
                                        color: AppColors.grey, fontSize: 13.sp),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            )
                            //   Expanded(child:
                            // //  CustomTextFoamField()
                            //   ),
                          ],
                        ),
                        CustomSizeBox(height: 10.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                                title: 'Email',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyblue),
                            CustomSizeBox(
                              width: 15.w,
                            ),

                            Container(
                              width: 225.w,
                              height: 45.h,
                              decoration: ShapeDecoration(
                                color: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(),
                                    borderRadius: BorderRadius.circular(4).r),
                                shadows: [
                                  BoxShadow(
                                    color: const Color(0x3F000000),
                                    blurRadius: 5.r,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Center(
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        bottom: 10.0, left: 10.0, top: 5),
                                    alignLabelWithHint: true,
                                    hintText: 'Email',
                                    hintStyle: TextStyle(
                                        color: AppColors.grey, fontSize: 13.sp),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            )
                            // Expanded(child: CustomTextFoamField()),
                          ],
                        ),
                        CustomSizeBox(height: 10.w),
                        Row(
                          children: [
                            imageFile == null
                                ? GestureDetector(
                                    onTap: () {
                                      showOptionsDialog(context);
                                    },
                                    child: CustomText(
                                        title: 'Choose Photo',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.navyblue),
                                  )
                                : Container(
                                    height: 50.h,
                                    width: 50.w,
                                    child: Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            CustomSizeBox(width: 40.w),
                            GestureDetector(
                              onTap: () {
                                AppConstants.showCustomSnackBar(
                                    "Image uploaded");
                              },
                              child: Container(
                                height: 35.h,
                                width: 80.w,
                                decoration: BoxDecoration(
                                    color: AppColors.navyblue,
                                    borderRadius: BorderRadius.circular(5.r)),
                                child: Center(
                                  child: CustomText(
                                    title: "Upload",
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.btntext,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () async {
                              if (emailController.text.isNotEmpty &&
                                  nameController.text.isNotEmpty) {
                                String name = '${userData['Name']}';
                                String bodyText = 'Package Guard';
                                String titleText =
                                    'Safe Circle request sent to ${nameController.text.toString()}!';

                                String titleText2 =
                                    'You have added ${nameController.text.toString()} to your Safe Circle';
                                String getCurrentUserId() {
                                  User? user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    return user.uid;
                                  } else {
                                    // Handle the case when there is no signed-in user.
                                    return 'No user signed in';
                                  }
                                }

                                User? user = FirebaseAuth.instance.currentUser;

                                if (name != "" &&
                                    emailController.text != userData['Email']) {
                                  DocumentSnapshot snap =
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(user?.uid)
                                          .get();

                                  String token = snap['deviceToken'];
                                  print(token);

                                  // String token =
                                  //     'co8eW22jT6afihnH21kcti:APA91bF62liQenFYZovy8Oh_VgamZS4Kt2p9GulvxkDexOVdtI_Xpv_K1yz6jdH5ztqKmUaUEtft82zBB9PjeolX0rDzMFNgQ8IzHz9i2AEiOHKtYKE2mBvfWyx72qAQ7EeEuxIj7zhc';

                                  sendMail(
                                    recipientEmail:
                                        emailController.text.toString(),
                                    mailMessage:
                                        'Welcome to safe circle'.toString(),
                                  );
                                  

                                  if (await checkIfExists(
                                      emailController.text)) {
                                    sendPushMessage(token, titleText, bodyText);
                                    // getPermit(emailController.text);
                                   String targetDeviceToken=await getTargetDeviceToken(emailController.text);

                                    sendPushMessageToTarget(targetDeviceToken,nameController.text);

                                    addPerson(
                                        recipientEmail:
                                            emailController.text.toString());
                                    saveUserNotificationToFirestore(
                                        emailController.text.toString(),
                                        nameController.text.toString(),
                                        titleText);
                                    await getReceiverUserId(
                                        emailController.text.toString());
                                    // saveCircleNotificationToFirestore(
                                    //   emailController.text.toString(),
                                    //   nameController.text.toString(),
                                    //   titleText2,
                                    // );

                                    // addNotification();
                                  } else {
                                    AppConstants.showCustomSnackBar(
                                        'Not an App user.');
                                  }
                                } else {
                                  AppConstants.showCustomSnackBar(
                                      "Email already exists");
                                }
                              } else {
                                // Handle the case where email or phone is empty
                                AppConstants.showCustomSnackBar(
                                    "Please fill in both email and phone.");
                              }
                            },
                            child: Container(
                              height: 48.h,
                              width: 80.w,
                              decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(8.r)),
                              child: Center(
                                child: CustomText(
                                  title: "Add",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CustomSizeBox(height: 80.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const AddPackageGuard());
                },
                child: Container(
                  // height: 30.h,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  width: 390.w,
                  decoration: BoxDecoration(
                      color: AppColors.navyblue,
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Center(
                    child: CustomText(
                      title: "Access Phone Contact",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> showOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: ListBody(
            children: [
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "From Camera",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  getFromCamera();
                  Navigator.pop(context);
                },
              ),
              Padding(padding: EdgeInsets.all(10.h)),
              GestureDetector(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "From Gallery",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  getFromGallery();
                  Navigator.pop(context);
                },
              ),
            ],
          )),
        );
      },
    );
  }
}



























// // ignore_for_file: unused_local_variable

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:mailer/mailer.dart' as mailer;
// import 'package:image_picker/image_picker.dart';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server/gmail.dart';
// import 'package:packageguard/Utils/app_colors.dart';
// import 'package:packageguard/Utils/app_images.dart';
// import 'package:packageguard/Widgets/custom_appbar.dart';
// import 'package:packageguard/firebase_options.dart';
// import 'package:velocity_x/velocity_x.dart';
// import '../../Utils/app_constants.dart';
// import '../../Widgets/custom_sized_box.dart';
// import '../../Widgets/custom_text.dart';
// import '../../Widgets/custom_text_foam_field.dart';
// import '../../Widgets/drawer.dart';
// import '../AddPackageGuard/add_packgard.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;

// import '../EditSafeCircle/edit_safecircle.dart';
// import '../Login/login.dart';

// String? mtoken = " ";

// class AddSafePerson extends StatefulWidget {
//   const AddSafePerson({super.key});

//   @override
//   State<AddSafePerson> createState() => _AddSafePersonState();
// }

// class _AddSafePersonState extends State<AddSafePerson> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   late AndroidNotificationChannel channel;
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   String? mtoken = "";
//   String? device_token = "";

//   File? imageFile;
//   String userId = '';
//   String receiverUserId = '';

//   final userController = Get.find<UserController>();

// // Access user data
//   Map<String, dynamic> userData = {};

//   @override
//   void initState() {
//     super.initState();
//     requestPermission();

//     loadFCM();

//     listenFCM();

//     getToken();

//     FirebaseMessaging.instance.subscribeToTopic("Animal");

//     // requestPermission();
//     // Access user data in initState or another method
//     userData = userController.userData as Map<String, dynamic>;
//   }

//   Future<bool> checkAlreadyExists(String inputEmail) async {
//     bool check = false;

//     String getCurrentUserId() {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         return user.uid;
//       } else {
//         // Handle the case when there is no signed-in user.
//         return 'No user signed in';
//       }
//     }

//     String userId = getCurrentUserId();

//     QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
//         .instance
//         .collection('safeCircle')
//         .doc(userId)
//         .collection('circlePersons')
//         .where('userEmail', isEqualTo: inputEmail)
//         .get();

//     // Check if any documents were found
//     return querySnapshot.docs.isNotEmpty;
//   }

//   Future<bool> checkIfExists(String inputEmail) async {
//     bool check = false;

//     try {
//       QuerySnapshot querySnapshot =
//           await FirebaseFirestore.instance.collection('users').get();

//       querySnapshot.docs.forEach((doc) {
//         final data = doc.data() as Map<String, dynamic>;

//         final email = data['Email'] as String?;

//         if (inputEmail == email) {
//           check = true;
//         }
//       });
// //for already in safe circl
//     } catch (e) {
//       print('Error checking if email exists: $e');
//     }

//     return check;
//   }


//   void saveToken(String token) async {
//     await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({
//       'token': token,
//     });
//   }

// Future<String?> getTargetDeviceToken(String userEmail) async {
//   String? deviceToken;

//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//       .collection('users') // Replace with your collection name
//       .where('Email', isEqualTo: userEmail) // Replace 'email' with your field name
//       .get();

//   if (querySnapshot.docs.isNotEmpty) {
//     // Assuming there's only one document with a matching email, retrieve the deviceToken
//     deviceToken = querySnapshot.docs.first.get('deviceToken');
//   } else {
//     print('No document found for email: $userEmail');
//   }

//   return deviceToken;
// }



//   void getToken() async {
//     await FirebaseMessaging.instance.getToken().then((token) {
//       setState(() {
//         mtoken = token;
//       });

//       saveToken(token!);
//     });
//   }

// //   String getCurrentUserId() {

// //   User? user = FirebaseAuth.instance.currentUser;
// //   if (user != null) {
// //     return user.uid;
// //   } else {
// //     // Handle the case when there is no signed-in user.
// //     return 'No user signed in';
// //   }
// // }
// // print(getCurrentUserId().toString());

//   Future<String> getReceiverUserId(String userEmail) async {
//     String titleText =
//         '${nameController.text.toString()}! has been added to your Safe Circle';
//     String titleText2 =
//         'You have added ${nameController.text.toString()} to your Safe Circle';
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .where('Email', isEqualTo: userEmail)
//         .get();

//     for (QueryDocumentSnapshot doc in querySnapshot.docs) {
//       receiverUserId = doc.id;
//       print('circle USER ID : $receiverUserId');
//       // saveUserNotificationToFirestore(emailController.text.toString(),
//       //     nameController.text.toString(), titleText);
//       saveCircleNotificationToFirestore(emailController.text.toString(),
//           nameController.text.toString(), titleText2, receiverUserId);
//       await SavaSenderIdToFireStore(receiverUserId);
//       // Use 'await' here if needed
//     }

//     return receiverUserId;
//   }

//   void saveUserNotificationToFirestore(
//       String userEmail, String userName, String titleText) async {
//     //Get userID of the current user
//     User? user = FirebaseAuth.instance.currentUser;
//     print('USER DATA: ${user}');
//     print('USER ID----: ${user?.uid}');

//     //Get userID of the receiver
//     // getReceiverUserId(userEmail);

//     final notificationData = {
//       // 'Device Token': device_token, // Add the device token field
//       'userEmail': userEmail, // Add user's email
//       'name': userName, // Add user's email
//       'notification': titleText, // Add the email from the input field
//       "timestamp": Timestamp.now(),
//     };

//     await FirebaseFirestore.instance
//         .collection('notifications')
//         .doc(user?.uid)
//         .collection("userNotification")
//         .add(notificationData);
//   }

//   SavaSenderIdToFireStore(String receiverId) async {
//     User? user = await FirebaseAuth.instance.currentUser;
//     await FirebaseFirestore.instance
//         .collection('status')
//         .doc(receiverId)
//         .set({userId: user});
//     print('REciever ID is ${receiverId}');
//   }

//   void saveCircleNotificationToFirestore(String userEmail, String userName,
//       String notification, String receiverId) async {
//     print('receiver id is:${receiverId}');
//     // String receiveId = await getReceiverUserId(userEmail);
//     var email;
//     User? user = await FirebaseAuth.instance.currentUser;

//     DocumentSnapshot<Map<String, dynamic>> recieverStatus =
//         await FirebaseFirestore.instance
//             .collection('status')
//             .doc(receiverId)
//             .get();
//     print('receiver user id is: ${recieverStatus['accept']}');

//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('notifications')
//         .doc(user?.uid)
//         .collection('safeCircleNotification')
//         .get();

//     querySnapshot.docs.forEach((doc) async {
//       final data = doc.data() as Map<String, dynamic>;

//       email = data['userEmail'] as String?;
//       print('RECIEPENT EMAIL: ${userEmail}');
//       print('DB EMAIL: ${email}');
//     });
//     if (userEmail != email) {
//       // print('reciver userId: ${receiveId}');

//       String notificationText =
//           'You have added ${nameController.text.toString()} to your Safe Circle';
//       String notificationText2 =
//           'You have been added to ${userData['Name']} safe circle for package protection';
//       final notificationData = {
//         // 'Device Token': device_token, // Add the device token field
//         'userEmail': userEmail, // Add user's email
//         'name': userName,
//         // Add user's email
//         'userId': receiverUserId.toString(),
//         'notification': notificationText2, // Add the email from the input field
//         "timestamp": Timestamp.now(),
//       };

//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(user?.uid)
//           .collection("safeCircleNotification")
//           .add(notificationData);
//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(receiverUserId)
//           .collection("safeCircleNotification")
//           .add(notificationData);
//     }
//   }

//   void sendPushMessage(String token, String body, String title) async {
//     try {
//       await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization':
//               'key=AAAA7uEFuE0:APA91bGrr2KX44UfRmYqbVpU5YCv7KIwJWi1cRxiq0dF7sMv2N5yT6paJTHXhdH9xUc7gd02Yhaa76TlsZmCLI1CQAxtBDkw2ylEKC6i6rPqdqaiy-OdJkFVhsYSShDmRfNXJ45pi8mq',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{
//               'title': title,
//               'body': body,

//               'icon':
//                   'https://firebasestorage.googleapis.com/v0/b/packageguard-d517e.appspot.com/o/app_logo%2Fic_launcher.png?alt=media&token=aa85c460-d622-4243-8ca0-bf9d81ed683f' // This should point to the icon image
//             },
//             'priority': 'high',
//             'data': <String, dynamic>{
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'id': '1',
//               'status': 'done'
//             },
//             'to': token,
//             // 'to': 'vKcfGYBymuNngtOmoAf4tPpGNyd2',
//           },
//         ),
//       );
//       print("here i am");
//     } catch (e) {
//       print("error push notification");
//     }
//   }

//   void requestPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print('User granted provisional permission');
//     } else {
//       print('User declined or has not accepted permission');
//     }
//   }

//   void listenFCM() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//       if (notification != null && android != null && !kIsWeb) {
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               // TODO add a proper drawable resource to android, for now using
//               //      one that already exists in example app.
//               icon: 'launch_background',
//             ),
//           ),
//         );
//       }
//     });
//   }

//   void loadFCM() async {
//     if (!kIsWeb) {
//       channel = const AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title
//         importance: Importance.high,
//         enableVibration: true,
//       );

//       flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//       /// Create an Android Notification Channel.
//       ///
//       /// We use this channel in the `AndroidManifest.xml` file to override the
//       /// default FCM channel to enable heads up notifications.
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);

//       /// Update the iOS foreground notification presentation options to allow
//       /// heads up notifications.
//       await FirebaseMessaging.instance
//           .setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }
//   }

//   void sendMail({
//     required String recipientEmail,
//     required String mailMessage,
//   }) async {
//     // change your email here
//     String username = 'danijakhar11@gmail.com';
//     // change your password here
//     String password = 'wxlthhhlaljgojjb';
//     final smtpServer = gmail(username, password);
//     final mailmessage = mailer.Message()
//       ..from = Address(username, 'Mail Service')
//       ..recipients.add(recipientEmail)
//       ..subject = 'Mail '
//       ..text = 'Message: $mailMessage';

//     try {
//       await send(mailmessage, smtpServer);
//       AppConstants.showCustomSnackBar('Email Sent Successfully');
//     } catch (e) {
//       if (kDebugMode) {
//         print(e.toString());
//       }
//     }
//   }

//   void addPerson({
//     required String recipientEmail,
//   }) async {
//     var email;
//     User? user = await FirebaseAuth.instance.currentUser;
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('safeCircle')
//         .doc(user?.uid)
//         .collection('circlePersons')
//         .get();

//     querySnapshot.docs.forEach((doc) async {
//       final data = doc.data() as Map<String, dynamic>;

//       email = data['userEmail'] as String?;
//       print('RECIEPENT EMAIL: ${recipientEmail}');
//       print('FB EMAIL: ${email}');
//     });
//     if (recipientEmail != email) {
//       await addSafePersonToFirestore(recipientEmail, nameController.text);
//       AppConstants.showCustomSnackBar("Person added to safe circle!");
//     } else {
//       AppConstants.showCustomSnackBar("Already added to safe circle.");
//     }

//     // Add data to Firestore

//     // Show a snackbar

//     // Navigate to the EditSafeCircle page
//     Get.to(() => EditSafeCircle());
//   }

//   void showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: FittedBox(
//           child: Text(
//             message,
//             style: const TextStyle(
//               fontSize: 10,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   getFromGallery() async {
//     final ImagePicker _picker = ImagePicker();
//     final pickedFile = await _picker.pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       imageFile = File(pickedFile.path);
//     }
//     setState(() {});
//   }

//   getFromCamera() async {
//     final ImagePicker _picker = ImagePicker();
//     final pickedFile = await _picker.pickImage(
//       source: ImageSource.camera,
//     );
//     if (pickedFile != null) {
//       imageFile = File(pickedFile.path);

//       print('IMAGW : $imageFile');
//     }
//     setState(() {});
//   }

//   Future<void> addSafePersonToFirestore(String addedEmail, String name) async {
//     FirebaseMessaging.instance.getToken().then((fcmToken) {
//       print("FCM Token: $fcmToken");
//       setState(() {
//         device_token = fcmToken;
//       });
//     });

//     String imageUrl = ''; // Initialize imageUrl with an empty string
//     try {
//       final user = FirebaseAuth.instance.currentUser;

//       if (user != null) {
//         final adminEmail = addedEmail; // Get the user's email
//         if (imageFile != null) {
//           imageUrl = (await uploadImageToFirebaseStorage(imageFile!))!;
//         }
//         if (adminEmail != null) {
//           final safeCircleData = {
//             // 'Device Token': device_token, // Add the device token field
//             'userEmail': adminEmail, // Add user's email
//             'deviceToken': device_token, // Add user's email
//             'userName': name, // Add the email from the input field
//             'image': imageUrl,
//           };
//           print('Device Token$mtoken');
//           print('User email$device_token ');

//           final firestore = FirebaseFirestore.instance;
//           // await firestore.collection('safeCircle').add(safeCircleData);
//           await firestore
//               .collection('safeCircle')
//               .doc(user?.uid)
//               .collection('circlePersons')
//               .add(safeCircleData);
//           AppConstants.showCustomSnackBar("Safe Circle Person added!");
//         } else {
//           AppConstants.showCustomSnackBar("Failed to get admin's email");
//         }
//       } else {
//         AppConstants.showCustomSnackBar("User not logged in");
//       }
//     } catch (e) {
//       print('Error adding data to Firestore: $e');
//       AppConstants.showCustomSnackBar("Error adding data to Firestore");
//     }
//   }

//   Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
//     try {
//       final Reference storageReference = FirebaseStorage.instance
//           .ref()
//           .child('SafeCircle_images')
//           .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

//       final UploadTask uploadTask = storageReference.putFile(imageFile);
//       await uploadTask;
//       final String imageUrl = await storageReference.getDownloadURL();
//       return imageUrl;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileImage = userData['ProfileImage'].toString().trim();
//     return SafeArea(
//         child: Scaffold(
//       drawer: MyDrawer(),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             CustomAppBar(
//               image: profileImage,
//               title: '${userData['Name']}',
//             ),
//             Container(
//               width: 358.w,
//               //  height: 336.h,
//               decoration: ShapeDecoration(
//                 color: const Color(0x2B15508D),
//                 shape: RoundedRectangleBorder(
//                   side: BorderSide(width: 1.w, color: const Color(0x7F15508D)),
//                   borderRadius: BorderRadius.circular(9.r),
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CustomText(
//                       title: 'Safe Circle',
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.navyblue,
//                     ),
//                     CustomSizeBox(height: 20.h),
//                     Row(
//                       children: [
//                         CustomSizeBox(width: 20.w),
//                         Image.asset(
//                           AppImages.vector,
//                           height: 120.h,
//                         ),
//                         CustomText(
//                           title:
//                               'Join your neighbor’s Safe Circle\nand have them join yours. The\nwhole street then becomes\npackage guardians.',
//                           fontSize: 10.sp,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w500,
//                         )
//                       ],
//                     ),
//                     CustomSizeBox(
//                       height: 15.h,
//                     ),
//                     Column(
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
//                               width: 13.w,
//                             ),

//                             // 5.widthBox,
//                             Container(
//                               width: 225.w,
//                               height: 45.h,
//                               decoration: ShapeDecoration(
//                                 color: AppColors.white,
//                                 shape: RoundedRectangleBorder(
//                                     side: BorderSide(),
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
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: nameController,
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.only(
//                                         bottom: 10.0, left: 10.0, top: 5),
//                                     hintText: 'Name',
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
//                                 title: 'Email',
//                                 fontSize: 12.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.navyblue),
//                             CustomSizeBox(
//                               width: 15.w,
//                             ),

//                             Container(
//                               width: 225.w,
//                               height: 45.h,
//                               decoration: ShapeDecoration(
//                                 color: AppColors.white,
//                                 shape: RoundedRectangleBorder(
//                                     side: BorderSide(),
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
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: emailController,
//                                   decoration: InputDecoration(
//                                     contentPadding: EdgeInsets.only(
//                                         bottom: 10.0, left: 10.0, top: 5),
//                                     alignLabelWithHint: true,
//                                     hintText: 'Email',
//                                     hintStyle: TextStyle(
//                                         color: AppColors.grey, fontSize: 13.sp),
//                                     border: InputBorder.none,
//                                   ),
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
//                               if (emailController.text.isNotEmpty &&
//                                   nameController.text.isNotEmpty) {
//                                 String name = '${userData['Name']}';
//                                 String bodyText = 'Package Guard';
//                                 String titleText =
//                                     '${nameController.text.toString()}! has been added to your Safe Circle';

//                                 String titleText2 =
//                                     'You have added ${nameController.text.toString()} to your Safe Circle';
//                                 String getCurrentUserId() {
//                                   User? user =
//                                       FirebaseAuth.instance.currentUser;
//                                   if (user != null) {
//                                     return user.uid;
//                                   } else {
//                                     // Handle the case when there is no signed-in user.
//                                     return 'No user signed in';
//                                   }
//                                 }

//                                 User? user = FirebaseAuth.instance.currentUser;

//                                 if (name != "" &&
//                                     emailController.text != userData['Email']) {
//                                   DocumentSnapshot snap =
//                                       await FirebaseFirestore.instance
//                                           .collection("UserTokens")
//                                           .doc("User1")
//                                           .get();

//                                   String token = snap['token'];
//                                   print(token);

//                                   // String token =
//                                   //     'co8eW22jT6afihnH21kcti:APA91bF62liQenFYZovy8Oh_VgamZS4Kt2p9GulvxkDexOVdtI_Xpv_K1yz6jdH5ztqKmUaUEtft82zBB9PjeolX0rDzMFNgQ8IzHz9i2AEiOHKtYKE2mBvfWyx72qAQ7EeEuxIj7zhc';

//                                   sendMail(
//                                     recipientEmail:
//                                         emailController.text.toString(),
//                                     mailMessage:
//                                         'Welcome to safe circle'.toString(),
//                                   );

//                                   if (await checkIfExists(
//                                       emailController.text)) {
//                                     bool alreadyExists =
//                                         await checkAlreadyExists(
//                                             emailController.text.toString());
//                                     if (!alreadyExists) {
//                                       sendPushMessage(token, titleText, bodyText);
//                                     String targetToken = getTargetDeviceToken(emailController.text).toString();
//                                     print("Target Token is $targetToken");
//                                     String targetBodyText='${userData['Name']} wants to add you in his safe circle';
//                                     String targetTitleText = 'Safe Circle Request';
//                                     print("Target Body text: $targetBodyText, Target title text: $targetTitleText");
//                                       // getPermit(emailController.text);
//                                       sendPushMessage(targetToken, targetTitleText, targetBodyText);

//                                       addPerson(
//                                           recipientEmail:
//                                               emailController.text.toString());
//                                       saveUserNotificationToFirestore(
//                                           emailController.text.toString(),
//                                           nameController.text.toString(),
//                                           titleText);
//                                       await getReceiverUserId(
//                                           emailController.text.toString());
//                                       // saveCircleNotificationToFirestore(
//                                       //   emailController.text.toString(),
//                                       //   nameController.text.toString(),
//                                       //   titleText2,
//                                       // );

//                                       // addNotification();
//                                     } else {
//                                       Get.snackbar(
//                                         'Already added',
//                                         'Please check the fields',
//                                         backgroundColor: Colors.red,
//                                         colorText: Colors.white,
//                                       );
//                                     }
//                                   } else {
//                                     AppConstants.showCustomSnackBar(
//                                         'Not an App user.');
//                                   }
//                                 } else {
//                                   AppConstants.showCustomSnackBar(
//                                       "Email already exists");
//                                 }
//                               } else {
//                                 // Handle the case where email or phone is empty
//                                 AppConstants.showCustomSnackBar(
//                                     "Please fill in both email and phone.");
//                               }
//                             },
//                             child: Container(
//                               height: 48.h,
//                               width: 80.w,
//                               decoration: BoxDecoration(
//                                   color: AppColors.green,
//                                   borderRadius: BorderRadius.circular(8.r)),
//                               child: Center(
//                                 child: CustomText(
//                                   title: "Add",
//                                   fontSize: 15.sp,
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
//               ),
//             ),
//             CustomSizeBox(height: 80.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: GestureDetector(
//                 onTap: () {
//                   Get.to(() => const AddPackageGuard());
//                 },
//                 child: Container(
//                   // height: 30.h,
//                   padding: EdgeInsets.symmetric(vertical: 15.h),
//                   width: 390.w,
//                   decoration: BoxDecoration(
//                       color: AppColors.navyblue,
//                       borderRadius: BorderRadius.circular(8.r)),
//                   child: Center(
//                     child: CustomText(
//                       title: "Access Phone Contact",
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ));
//   }

//   Future<void> showOptionsDialog(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//               child: ListBody(
//             children: [
//               GestureDetector(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.camera,
//                       size: 20.sp,
//                       color: Colors.black,
//                     ),
//                     SizedBox(width: 10.w),
//                     Text(
//                       "From Camera",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   getFromCamera();
//                   Navigator.pop(context);
//                 },
//               ),
//               Padding(padding: EdgeInsets.all(10.h)),
//               GestureDetector(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.image,
//                       size: 20.sp,
//                       color: Colors.black,
//                     ),
//                     SizedBox(width: 10.w),
//                     Text(
//                       "From Gallery",
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 onTap: () {
//                   getFromGallery();
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           )),
//         );
//       },
//     );
//   }
// }
