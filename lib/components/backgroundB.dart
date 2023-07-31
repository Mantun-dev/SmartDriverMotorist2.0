import 'package:flutter/material.dart';

class BackgroundBody extends StatelessWidget {
  final Widget child;
  const BackgroundBody({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}