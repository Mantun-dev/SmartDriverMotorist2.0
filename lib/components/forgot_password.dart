import 'package:flutter/material.dart';
import '../constants.dart';

class ForgotPassword extends StatelessWidget {
  final bool login;
  final Function press;
  const ForgotPassword({Key key, this.login = true, this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login
              ? "¿Olvidaste tu contraseña? "
              : "¿Quieres reestablecer contraseña? ",
          style: TextStyle(color: kPrimaryColor),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Ingresa aquí" : "Ingresa aquí",
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
