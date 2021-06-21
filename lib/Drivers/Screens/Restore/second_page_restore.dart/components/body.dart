import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Login/login_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Register/components/rounded_password_field.dart';
import 'package:flutter_auth/Drivers/Screens/Restore/components/background.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_input_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "REESTABLECER CONTRASEÑA",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/Password.svg",
              height: size.height * 0.35,
            ),
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text('Ingresa una nueva contraseña',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                )),
            RoundedInputField(
              hintText: "Nombre de usuario",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedPasswordFieldRegister(
              onChanged: (value) {},
            ),
            RoundedButton(
                text: "CONFIRMAR",
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return LoginScreen();
                  }));
                }),
            SizedBox(height: size.height * 0.05),
          ],
        ),
      ),
    );
  }
}
