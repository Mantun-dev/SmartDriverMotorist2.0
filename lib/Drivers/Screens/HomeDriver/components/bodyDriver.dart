import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/driverBackground.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/itemDriver_Card.dart';
//import 'package:flutter_auth/Drivers/components/descriptionDriver.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import '../../../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with AutomaticKeepAliveClientMixin<Body>{
  //final si = DriverDescription();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DriverBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 70.0),
            //texto inicial
            child: Text(
              "Smart Driver",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          //Categories(),
          SizedBox(height: 30.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: GridView.builder(
                  itemCount: plantillaDriver.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: kDefaultPadding,
                    crossAxisSpacing: kDefaultPadding,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) => ItemDriverCard(
                        plantillaDriver: plantillaDriver[index],
                        press: () {
                        // si.method();                
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsDriverScreen(
                                  plantillaDriver: plantillaDriver[index],
                                ),
                              ));
                        } 
                      )),
            ),
          ),
          //Positioned(child: Icon(Icons.brightness_1)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
