import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/Screens/Login/components/background.dart';

import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/dataToken.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';

import 'package:flutter_auth/components/rounded_button.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import '../../../../constants.dart';

class Body extends StatefulWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController driverPassword = new TextEditingController();
  TextEditingController driverDNI = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  bool? _passwordVisible;

  @override
  void initState() {
    super.initState();
    driverDNI = new TextEditingController(text: prefs.nombreUsuario);
    driverPassword = new TextEditingController(text: prefs.passwordUser);
    _passwordVisible = true;
  }

  Future<dynamic> fetchUserDriver(
      String driverDNI, String driverPassword) async {
    Map data = {'driverDNI': driverDNI, 'driverPassword': driverPassword};
    String device = "mobile";
    if (driverDNI == "" && driverPassword == "") {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Alerta",
      text: "Campos vacios",
      );

    } else {
      http.Response responses = await http
          .get(Uri.parse('$ip/apis/refreshingAgentData/${data['driverDNI']}'));
      final si = DriverData.fromJson(json.decode(responses.body));
      Map data2 = {
        'driverId': '${si.driverId}',
        'device': device,
        'deviceId': PushNotificationServices.token.toString()
      };

      http.Response response = await http.post(
        Uri.parse('$ip/apis/login'),
        body: data,
      );
      final no = Message.fromJson(json.decode(response.body));

      if (response.statusCode == 200 &&
          no.ok == true &&
          responses.statusCode == 200) {
        http.Response responseToken = await http.post(
          Uri.parse('$ip/apis/registerTokenIdCellPhoneDriver'),
          body: data2,
        );
        prefs.nombreUsuarioFull = si.driverFullname!;
        prefs.phone = si.driverPhone!;
        prefs.nombreUsuario = si.driverUser!;
        final claro = DataToken.fromJson(json.decode(responseToken.body));
        prefs.tokenIdMobile = claro.data![0].token!;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => HomeDriverScreen()),
            (Route<dynamic> route) => false);
            QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title:"Bienvenido(a)",
            text: si.driverFullname,
            );

        return Message.fromJson(json.decode(response.body));
      } else if (no.ok == false && response.statusCode == 403) {
         QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title:"Acceso no admitido ",
            text: no.message,
            );
      } else if (no.ok != true) {
         QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title:"Alerta",
            text: no.message,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.04),
            Text(
              "INGRESA",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 30, color: firstColor),
            ),
            Lottie.asset('assets/videos/login.json'),
            SizedBox(height: size.height * 0.03),
            _crearUsuario(),
            SizedBox(height: size.height * 0.01),
            _crearPassword(),
            SizedBox(height: size.height * 0.03),
            RoundedButton(
              color: thirdColor,
              text: "INGRESA ",
              press: () {
                FocusScope.of(context).unfocus();
                fetchUserDriver(driverDNI.text, driverPassword.text);
              },
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _crearUsuario() {
    return Container(
      margin: EdgeInsets.only(left: 35, right: 35),
      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 50),
      decoration: BoxDecoration(
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: [Gradiant1, Gradiant2]),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(50)),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: driverDNI,
        cursorColor: firstColor,
        decoration: InputDecoration(
          icon: Icon(
            Icons.person,
            color: thirdColor,
            size: 30,
          ),
          hintText: "Usuario",
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _crearPassword() {
    return Container(
      margin: EdgeInsets.only(left: 35, right: 35),
      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      decoration: BoxDecoration(
          border: const GradientBoxBorder(
            gradient: LinearGradient(colors: [Gradiant1, Gradiant2]),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(50)),
      child: TextField(
        style: TextStyle(color: Colors.white),
        //keyboardType: TextInputType.,
        controller: driverPassword,
        obscureText: _passwordVisible!,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "Contraseña",
          hintStyle: TextStyle(color: Colors.white),
          icon: Icon(
            Icons.lock,
            color: thirdColor,
            size: 30,
          ),
          suffixIcon: IconButton(
            padding: EdgeInsets.only(left: 10),
            tooltip: 'Ver contraseña',
            icon: Icon(
              // Based on passwordVisible state choose the icon
              _passwordVisible ?? true
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: thirdColor,
              size: 30,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                _passwordVisible = !_passwordVisible!;
              });
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
