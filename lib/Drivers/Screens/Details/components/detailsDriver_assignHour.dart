import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/bodyDriver_Details.dart';

import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';

import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/components/AppBarPosterior.dart';
import 'package:flutter_auth/components/AppBarSuperior.dart';

import '../../../../components/backgroundB.dart';
//import 'package:flutter/scheduler.dart';

class DetailsDriverHour extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;

  const DetailsDriverHour({Key? key, this.plantillaDriver}) : super(key: key);

  @override
  _DetailsDriverHourState createState() => _DetailsDriverHourState();
}

class _DetailsDriverHourState extends State<DetailsDriverHour> {
  final prefs = new PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 1,)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: Body(plantillaDriver: widget.plantillaDriver)),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }
}
