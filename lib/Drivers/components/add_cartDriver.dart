import 'package:flutter/material.dart';
import '../../constants.dart';

class AddToCartDriver extends StatefulWidget {
  const AddToCartDriver({
    Key key,
  }) : super(key: key);

  @override
  _AddToCartDriverState createState() => _AddToCartDriverState();
}

class _AddToCartDriverState extends State<AddToCartDriver> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding));
  }
}
