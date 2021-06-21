import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import '../constants.dart';

class PlantillaTitleWithImage extends StatelessWidget {
  const PlantillaTitleWithImage({
    Key key,
    @required this.plantilla,
  }) : super(key: key);

  final PlantillaDriver plantilla;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            plantilla.title,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0),
          Row(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    //aquí le mandamos el hola en la página después de tocar la imagen
                    TextSpan(text: ""),
                    TextSpan(
                      //y el nombre
                      text: "${plantilla.name}",
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 90),
              Expanded(
                child: Hero(
                  //aquí esta el otro id
                  tag: "${plantilla.id}",
                  child: Image.asset(
                    plantilla.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
