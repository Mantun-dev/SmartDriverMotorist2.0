import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Login/components/body.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo.png'), 
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Body(),
          ),
        ),
      ),
    );
  }
}
