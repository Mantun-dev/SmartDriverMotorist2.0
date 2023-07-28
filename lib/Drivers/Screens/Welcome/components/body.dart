import 'package:flutter/material.dart';
import '../../Login/login_screen.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [

          Positioned(
            top: 80,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 330,
                maxHeight: 110,
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
          ),


          Positioned(
            top: 350,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.white),
                fixedSize: Size(size.width-80, 50)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 200 ), // Adjust the animation duration as needed
                    pageBuilder: (_, __, ___) => LoginScreen(),
                    transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Text(
                "Ingresar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.normal
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[              
              Text(
                'Hecho con ',
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.favorite_outline, color: Colors.white),
              SizedBox(
                width: 3,
              ),
              Text(
                ' por',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 3,
              ),
              Text(
                'MANTUN',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50)
            ])
          )
        ],
      ),
    );
  }
}