import 'package:flutter/material.dart';

import 'package:flutter_auth/constants.dart';

class CartCounter extends StatefulWidget {
  CartCounter({Key key}) : super(key: key);

  @override
  _CartCounterState createState() => _CartCounterState();
}

class _CartCounterState extends State<CartCounter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
    );
  }

  SizedBox builOutlineButton({IconData icon, Function press}) {
    return SizedBox(
      width: 40,
      height: 32,
    );
  }
}
