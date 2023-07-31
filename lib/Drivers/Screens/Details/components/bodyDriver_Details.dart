import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';

class Body extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;

  const Body({Key? key, this.plantillaDriver}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    // It provide us total height and width

    return SingleChildScrollView(
      child: DriverDescription(plantillaDriver: widget.plantillaDriver!,)
    );
  }
}
