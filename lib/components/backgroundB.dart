import 'package:flutter/material.dart';

class BackgroundBody extends StatelessWidget {
  final Widget child;
  const BackgroundBody({
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
                        
                        Container(
                            width: size.width,
                            height: size.height / 2.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
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