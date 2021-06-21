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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: widget.plantillaDriver.color,
                borderRadius: BorderRadius.circular(16),
              ),
              //aquí haces la animación de la página principal a las demás
              child: Hero(
                tag: "${widget.plantillaDriver.id}",
                child: Image.asset(widget.plantillaDriver.image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
            child: Text(
              widget.plantillaDriver.title,
              textAlign: TextAlign.end,
              style: TextStyle(color: kTextColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
