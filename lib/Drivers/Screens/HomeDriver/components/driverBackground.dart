import 'package:flutter/material.dart';

class DriverBackground extends StatefulWidget {
  final Widget child;
  const DriverBackground({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _DriverBackgroundState createState() => _DriverBackgroundState();
}

class _DriverBackgroundState extends State<DriverBackground> {
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_Drivertop.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: 650,
            bottom: 0,
            child: Image.asset(
              "assets/images/main_Driverbottom.png",
              width: size.width,
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
