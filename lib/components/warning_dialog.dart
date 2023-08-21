import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum QuickAlertType {
  warning,
  // Otros tipos de alerta
}

class WarningDialog {
  static final WarningDialog _singleton = WarningDialog._internal();
  late BuildContext _context;
  bool isDisplayed = false;

  factory WarningDialog() {
    return _singleton;
  }

  WarningDialog._internal();

  show(BuildContext context, {
    required String title,
    required VoidCallback onOkay,
  }) {
    if (isDisplayed) {
      return;
    }
    Color containerC = Color.fromRGBO(40, 93, 169, 1);
    String iconAsset = "assets/icons/advertencia.svg";
    Size size = MediaQuery.of(context).size;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _context = context;
        isDisplayed = true;
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: SingleChildScrollView(
              child: Column(

                children: [
                  Container(
                    width: size.width*0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      color: containerC,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top:30, bottom: 30),
                      child: SvgPicture.asset(
                        iconAsset,
                        height: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),


                  Container(
                    width: size.width*0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      color: Colors.white, 
                    ),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Color.fromRGBO(40, 93, 169, 1)),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(40, 93, 169, 1)),
                          ),
                          onPressed: () {
                            onOkay();
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  dismiss() {
    if (isDisplayed) {
      Navigator.pop(_context);
      isDisplayed = false;
    }
  }
}