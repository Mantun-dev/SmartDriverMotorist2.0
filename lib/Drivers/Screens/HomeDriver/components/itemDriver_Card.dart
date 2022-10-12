import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';

import '../../../../constants.dart';

class ItemDriverCard extends StatefulWidget {
  final PlantillaDriver plantillaDriver;
  final Function press;
  const ItemDriverCard({
    Key key,
    this.plantillaDriver,
    this.press,
  }) : super(key: key);

  @override
  _ItemDriverCardState createState() => _ItemDriverCardState();
}

class _ItemDriverCardState extends State<ItemDriverCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: "${widget.plantillaDriver.id}",
                            child: Container(
                              padding: EdgeInsets.only(top: 15),
                              // padding: EdgeInsets.only(right: 150),
                              height: 100,
                              child: Image.asset(
                                widget.plantillaDriver.image,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12, left: 10),
                            child: Text(
                              widget.plantillaDriver.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: GradiantV_2,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12, left: 10),
                            child: Text(
                              widget.plantillaDriver.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              width: 320,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: Offset(0, 0)),
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(5, 5)),
                ],
                color: widget.plantillaDriver.color,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
