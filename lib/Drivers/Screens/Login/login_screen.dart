import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Login/components/body.dart';
import 'package:flutter_auth/constants.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Body(),
      ),
    );
  }
}
