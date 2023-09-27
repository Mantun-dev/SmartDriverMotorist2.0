import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';

import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/dataToken.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';

import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
//import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import '../../../../components/progress_indicator.dart';
import '../../../../components/warning_dialog.dart';
import '../../../../constants.dart';
import '../../Welcome/welcome_screen.dart';

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
      WarningSuccessDialog().show(
              context,
              title: 'Campos vacios',
              tipo: 1,
              onOkay: () {},
            );

    } else {
      LoadingIndicatorDialog().show(context);
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
        
        LoadingIndicatorDialog().dismiss();
        
        if(mounted){
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => HomeDriverScreen()),
            (Route<dynamic> route) => false);
            WarningSuccessDialog().show(
              context,
              title: 'Bienvenido(a) ${si.driverFullname}',
              tipo: 2,
              onOkay: () {},
            );

          return Message.fromJson(json.decode(response.body));
        }
      } else if (no.ok == false && response.statusCode == 403) {
        LoadingIndicatorDialog().dismiss();
         if(mounted){
          WarningSuccessDialog().show(
              context,
              title: 'Acceso no admitido',
              tipo: 1,
              onOkay: () {},
            );
         }
      } else if (no.ok != true) {
        LoadingIndicatorDialog().dismiss();
         if(mounted){
           WarningSuccessDialog().show(
              context,
              title: '${no.message}',
              tipo: 1,
              onOkay: () {},
            );
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      child: Stack(

        children: [

          Positioned(
            top: 20,
            child: Container(
              width: size.width,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 40, right: 40),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                            pageBuilder: (_, __, ___) => WelcomeScreen(),
                            transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(-1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SvgPicture.asset(
                            "assets/icons/flecha_atras_oscuro.svg",
                            color: Colors.white,
                            width: 5,
                            height: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
  
                  Center(child: Text("Iniciar sesión",style: TextStyle(color: Colors.white,fontSize: 27),)),
                ],
              ),
            ),
          ),

          Positioned(
            top: 100,
            right: 0,
            left: 0,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 180,
                maxHeight: 180,
              ),
              child: Lottie.asset('assets/videos/100966-login-successful.json')
            ),
          ),

          Positioned.fill(
            top: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width,
                  margin: EdgeInsets.only(left: 40, right: 40),
                  child: Column(children: [
                    _crearUsuario(),
                    SizedBox(height: 10),
                    _crearPassword(),
                    SizedBox(height: 20),
                  ]),
                ),
                SizedBox(height: 15),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.white),
                  fixedSize: Size(size.width-80, 50)
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    fetchUserDriver(driverDNI.text, driverPassword.text);
                  },
                  child: Text(
                    "Ingresar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.normal
                    ),
                  ),
                ),
            
              ],
            ),
          ),

          Positioned(
            bottom: 10,
            child: Text('')
          )
        ],
      ),
    );
  }

  Widget _crearUsuario() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            controller: driverDNI,
            cursorColor: firstColor,
            decoration: InputDecoration(
              icon: SvgPicture.asset(  
                  "assets/icons/usuario.svg",
                  color: Colors.white,
                  width: 20,
                  height: 20,
                ),
              hintText: "Número de identidad",
              hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
              border: InputBorder.none,
            ),
          ),
        ),
        Divider(
          color: Color.fromRGBO(158, 158, 158, 1),
          thickness: 1.0,
        )
      ],
    );
  }

  Widget _crearPassword() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            //keyboardType: TextInputType.,
            controller: driverPassword,
            obscureText: _passwordVisible!,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: "Contraseña",
              hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
              icon: SvgPicture.asset(  
                  "assets/icons/candado.svg",
                  color: Colors.white,
                  width: 25,
                  height: 25,
                ),
              suffixIcon: IconButton(
                padding: EdgeInsets.only(left: 10),
                tooltip: 'Ver contraseña',
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passwordVisible ?? false
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white,
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
        ),
        Divider(
          color: Color.fromRGBO(158, 158, 158, 1),
          thickness: 1.0,
        )
      ],
    );
  }
}
