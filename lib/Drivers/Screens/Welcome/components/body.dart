import 'package:flutter/material.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/constants.dart';

import 'package:lottie/lottie.dart';

import '../../Login/components/background.dart';
import '../../Login/login_screen.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text(
              "Bienvenido a",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w400, color: firstColor),
            ),
            Text(
              'SMART DRIVER',
              style: TextStyle(
                  fontSize: 35, fontWeight: FontWeight.bold, color: firstColor),
            ),
            Lottie.asset('assets/videos/welcome.json'),
            RoundedButton(
              text: "INGRESAR",
              color: thirdColor,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment : MainAxisAlignment.center,
              //crossAxisAlignment : CrossAxisAlignment.center,
              children: <Widget>[
              //SizedBox(width: 100),
              Text(
                'Made with',
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.favorite, color: fourthColor),
              SizedBox(
                width: 3,
              ),
              Text(
                'by',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                'MANTUN',
                style:
                    TextStyle(color: secondColor, fontWeight: FontWeight.bold),
              )
            ])
          ],
        ),
      ),
    );
  }
}
