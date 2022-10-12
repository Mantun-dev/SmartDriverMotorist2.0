import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Welcome/components/body.dart';
import 'package:flutter_auth/constants.dart';

class WelcomeScreen extends StatelessWidget {
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
