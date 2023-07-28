import 'package:flutter/material.dart';

class BackgroundHome extends StatelessWidget {
  final Widget child;
  const BackgroundHome({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        
                        Positioned(
                            top: -100,
                            right: -40,
                            left: -40,
                            child: Container(
                              width: size.width + 200,
                              height: size.height / 2.2,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                          ),
                          child,
                      ],
                    ),
                  ),
                ],
              ),
            );
  }
}