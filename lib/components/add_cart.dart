import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/constants.dart';

class AddToCart extends StatelessWidget {
  const AddToCart({
    Key? key,
    required this.plantilla,
  }) : super(key: key);

  final PlantillaDriver plantilla;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: Row(
        children: <Widget>[],
      ),
    );
  }
}
