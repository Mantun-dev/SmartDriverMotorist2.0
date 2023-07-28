import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_svg/svg.dart';

class ItemDriverCard extends StatefulWidget {
  final PlantillaDriver? plantillaDriver;
  final VoidCallback? press;
  final bool? viajeSolido;
  const ItemDriverCard({
    Key? key,
    this.plantillaDriver,
    this.press,
    this.viajeSolido
  }) : super(key: key);

  @override
  _ItemDriverCardState createState() => _ItemDriverCardState();
}

class _ItemDriverCardState extends State<ItemDriverCard> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.press,
      child: Container(
        decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).disabledColor
                  )
                ),

        child: Padding(
          padding:  widget.viajeSolido != true ? EdgeInsets.symmetric(vertical: 20, horizontal: 10):EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).shadowColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 60,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(
                    widget.plantillaDriver!.image!,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ),
              ),

              SizedBox(height: 12),

              Text(
                widget.plantillaDriver!.title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15),
              ),

              SizedBox(height: 6),

              Text(
                widget.plantillaDriver!.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      )

    );
  }
}
