import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/bodyDriver_Details.dart';

import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';

import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
//import 'package:flutter/scheduler.dart';
import '../../../constants.dart';

class DetailsDriverScreen extends StatefulWidget {
  final PlantillaDriver plantillaDriver;

  const DetailsDriverScreen({Key key, this.plantillaDriver}) : super(key: key);

  @override
  _DetailsDriverScreenState createState() => _DetailsDriverScreenState();
}

class _DetailsDriverScreenState extends State<DetailsDriverScreen> {

  final prefs = new PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // each product have a color
      backgroundColor: widget.plantillaDriver.color,
      drawer: DriverMenuLateral(),
      appBar: buildAppBar(context),
      body:  GestureDetector(
        onTap: () {   
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Body(
          plantillaDriver: widget.plantillaDriver)),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: widget.plantillaDriver.color,
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>
            HomeDriverScreen()),(Route<dynamic> route) =>false);
          },
        ),
        SizedBox(width: kDefaultPadding / 2)
      ],
    );
  }
}
