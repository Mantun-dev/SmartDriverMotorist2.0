import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants.dart';

class PlantillaDriverTitleWithImage extends StatelessWidget {
  const PlantillaDriverTitleWithImage({
    Key? key,
    required this.plantillaDriver,
  }) : super(key: key);

  final PlantillaDriver plantillaDriver;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    // Padding(
                    //   //padding: const EdgeInsets.only(right: 5.0),
                    //   child: 
                      Text(
                        plantillaDriver.title!,
                        style: TextStyle(
                            fontSize: 20,
                            color: backgroundColor,
                            fontWeight: FontWeight.bold),
                      ),
                    //),
                  ],
                ),
              ),
              Container(
                width: 100,
                child: Column(
                  children: [
                    Hero(
                      tag: "${plantillaDriver.id}",
                      child: SvgPicture.asset(
                        plantillaDriver.imageMain!,
                        fit: BoxFit.contain,
                        height: 140,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
