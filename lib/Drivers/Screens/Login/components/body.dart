import 'package:flutter/material.dart';
//import 'package:flutter_auth/Agents/Screens/HomeAgents/homeScreen_Agents.dart';
// import 'package:flutter_auth/Agents/Screens/Login/components/background.dart';
// import 'package:flutter_auth/Agents/Screens/Restore/restore_screen.dart';
// import 'package:flutter_auth/Agents/Screens/Signup/signup_screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/Screens/Login/components/background.dart';
import 'package:flutter_auth/Drivers/Screens/Restore/restore_screen.dart';
import 'package:flutter_auth/Drivers/Screens/Signup/signup_screen.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/SharePreferences/services.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/dataToken.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/components/already_have_an_account_acheck.dart';
import 'package:flutter_auth/Drivers/Screens/forgot_password.dart';
import 'package:flutter_auth/components/rounded_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;

import '../../../../components/text_field_container.dart';
import '../../../../constants.dart';

class Body extends StatefulWidget {
  const Body({
    Key key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController driverPassword = new TextEditingController();
  TextEditingController driverDNI = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  bool _passwordVisible;
  
     @override
  void initState() {
    super.initState();
    driverDNI = new TextEditingController( text: prefs.nombreUsuario );
    driverPassword = new TextEditingController(text: prefs.passwordUser);
    _passwordVisible = false;
  }

  Future<dynamic>fetchUserDriver(String driverDNI, String driverPassword) async {
    Map data = {
      'driverDNI' : driverDNI,
      'driverPassword' : driverPassword
    };
    String device = "mobile";
    if (driverDNI == ""&& driverPassword == "") {
        SweetAlert.show(context,
          title: "Alerta",
          subtitle: "Campos vacios",
          style: SweetAlertStyle.error,
        );
      }else{
        http.Response responses = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${data['driverDNI']}'));
        final si = DriverData.fromJson(json.decode(responses.body));
        prefs.nombreUsuarioFull = si.driverFullname;
        prefs.phone = si.driverPhone;
        Map data2 = {
          'driverId' : '${si.driverId}',
          'device' : device,
          'deviceId': PushNotificationServices.token.toString()
        };
    

        http.Response response = await http.post(Uri.encodeFull('$ip/apis/login'), body: data,);
        final no = Message.fromJson(json.decode(response.body));   

        if (response.statusCode == 200 && no.ok == true && responses.statusCode == 200) {  
          http.Response responseToken = await http.post(Uri.encodeFull('$ip/apis/registerTokenIdCellPhoneDriver'), body: data2,);
          final claro = DataToken.fromJson(json.decode(responseToken.body));     
          prefs.tokenIdMobile = claro.data[0].token;
            //print(responseToken.body);                          
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context)=>
          HomeDriverScreen()), (Route<dynamic> route) => false);
          SweetAlert.show(context,
            title: "Bienvenido(a)",
            subtitle: si.driverFullname,
            style: SweetAlertStyle.success
          );
          return Message.fromJson(json.decode(response.body));
          } else if (no.ok != true) {
            SweetAlert.show(context,
              title: "Alerta",
              subtitle: no.message,
              style: SweetAlertStyle.error,
            );
          }
      }
  } 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(

      child: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "INGRESA",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.48,
              ),
              SizedBox(height: size.height * 0.01),
              _crearUsuario(),
              _crearPassword(),
              RoundedButton(
                text: "INGRESA ",
                press: () {
                  fetchUserDriver(driverDNI.text, driverPassword.text);   
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: size.height * 0.01),
              ForgotPassword(
                press: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return RestoreScreen();
                  }));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

    Widget _crearUsuario(){
    return TextFieldContainer(
      child: TextField(
        controller: driverDNI,
        //onChanged: onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            Icons.person,
            color: kPrimaryColor,
          ),
          hintText: "Número de identidad",
          border: InputBorder.none,
        ),
        onChanged: ( value ) {
          prefs.nombreUsuario = value;
        },
    ),
    );
  }

  Widget _crearPassword(){
    return TextFieldContainer(
     child: TextField(
      controller: driverPassword,
      obscureText:  !_passwordVisible,
      onChanged: (value){
        prefs.passwordUser = value;
      },
      cursorColor: kPrimaryColor,
      decoration: InputDecoration(
        hintText: "Contraseña",
        icon: Icon(
          Icons.lock,
          color: kPrimaryColor,
        ),
        suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible
                ? Icons.visibility
                : Icons.visibility_off,
                color: kPrimaryColor,
                ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                    _passwordVisible = !_passwordVisible;
                });
              },
              ),
          border: InputBorder.none,
       
      ),
    ),
    );
  }
}
