import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import '../../constants.dart';

class PlantillaDriverTitleWithImage extends StatelessWidget {
  const PlantillaDriverTitleWithImage({
    Key key,
    @required this.plantillaDriver,
  }) : super(key: key);

  final PlantillaDriver plantillaDriver;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            plantillaDriver.title,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: [
                    //aquí le mandamos el hola en la página después de tocar la imagen
                    TextSpan(text: ""),
                  ],
                ),
              ),
       
              Container(                                 
                width: 150,
                height: 150,
                child: Hero(
                    //aquí esta el otro id
                    tag: "${plantillaDriver.id}",
                    child: Image.asset(
                      plantillaDriver.image,
                      fit: BoxFit.contain,
                    ),
                  ),
               ),
              
            ],
          ),
          //validationButtonsScanner(context),
        ],
      ),
    );
  }
}
