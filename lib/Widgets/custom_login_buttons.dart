import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

class LoginButton extends StatefulWidget {
  Callback onPressed;
  LoginButton({
    super.key,
    required this.onPressed,
    

  
  
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}