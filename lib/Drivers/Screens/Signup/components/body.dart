import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Login/login_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Register/register_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Signup/components/background.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_input_field.dart';
import 'package:flutter_auth/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';

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
              "REGÍSTRATE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "Escribe tu usuario designado y un correo válido, se enviará un código de confirmación para que puedas registrarte",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            RoundedInputField(
              hintText: "Ingresa tu email",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "SOLICITAR CÓDIGO",
              press: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RegisterScreen();
                }));
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
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
            //   OrDivider(),
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       SocalIcon(
            //         iconSrc: "assets/icons/facebook.svg",
            //         press: () {},
            //       ),
            //       SocalIcon(
            //         iconSrc: "assets/icons/twitter.svg",
            //         press: () {},
            //       ),
            //       SocalIcon(
            //         iconSrc: "assets/icons/google-plus.svg",
            //         press: () {},
            //       ),
            //     ],
            //   )
          ],
        ),
      ),
    );
  }
}
