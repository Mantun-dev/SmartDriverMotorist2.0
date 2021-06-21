import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Restore/components/background.dart';
import 'package:flutter_auth/Drivers/Screens/Restore/second_page_restore.dart/second_restore_screen.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_auth/components/rounded_input_field.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Body extends StatelessWidget {
  const Body({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(
                "REESTABLECER CONTRASEÑA",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: SvgPicture.asset(
                "assets/icons/driver.svg",
                height: size.height * 0.50,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 2.0),
              child: Center(
                child: Text(
                  'Escribe tu nombre de usuario, se enviará un enlace al correo para reestablecer tu contraseña',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: (18.0)),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: RoundedInputField(
                hintText: 'Ingresa tu usuario',
                onChanged: (value) {},
              ),
            ),
            RoundedButton(
                text: 'Enviar',
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SecondRestoreScreen();
                  }));
                }),
          ],
        ),
      ),
    );
  }
}
