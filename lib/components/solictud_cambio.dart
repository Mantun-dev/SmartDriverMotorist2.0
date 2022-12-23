import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

class SolicitudCambio extends StatelessWidget {
  final bool? profile;
  final VoidCallback?  press;
  const SolicitudCambio({
    Key? key,
    this.profile = true,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                profile! ? '¿Es su informacion incorrecta?' : "",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 13,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: press,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                profile! ? "\tSolicite cambio aquí." : "",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 13,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
