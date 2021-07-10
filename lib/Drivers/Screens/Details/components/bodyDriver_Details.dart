import 'package:flutter/material.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/components/add_cartDriver.dart';
import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:flutter_auth/Drivers/components/plantillaDriver_titleWithImage.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';


class Body extends StatefulWidget {
  final PlantillaDriver plantillaDriver;

  const Body({Key key, this.plantillaDriver}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    // It provide us total height and width
    Size size = MediaQuery.of(context).size;
    return  ListView(      
        children: <Widget>[
          //en esta pintamos las páginas después de tocar las imagenes
          SizedBox(            
            height: size.height,            
            child: Stack(
              children: <Widget>[
                Container(
                  width: size.width,
                  height: size.height,
                  margin: EdgeInsets.only(top: size.height * 0.25),
                  padding: EdgeInsets.only(
                    top: 50.0,),
                  decoration: BoxDecoration(                    
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(                    
                    child: Column(
                      children: <Widget>[
                        DriverDescription(plantillaDriver: widget.plantillaDriver,),
                        AddToCartDriver(),
                      ],
                    ),
                  ),
                ),
                PlantillaDriverTitleWithImage(plantillaDriver: widget.plantillaDriver)
              ],
            ),
          )
        ],
      );
  }
}
