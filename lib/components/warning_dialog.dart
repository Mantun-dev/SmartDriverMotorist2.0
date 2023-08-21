import 'package:flutter/material.dart';
import 'package:flutter_auth/main.dart';
import 'package:flutter_svg/svg.dart';

enum QuickAlertType {
  warning,
  // Otros tipos de alerta
}

class Warning_SuccessDialog {
  static final Warning_SuccessDialog _singleton = Warning_SuccessDialog._internal();
  late BuildContext _context;
  bool isDisplayed = false;

  factory Warning_SuccessDialog() {
    return _singleton;
  }

  Warning_SuccessDialog._internal();

  show(BuildContext context, {
    required String title,
    required int tipo,
    required VoidCallback onOkay,
  }) {
    if (isDisplayed) {
      return;
    }
    Color containerC = Color.fromRGBO(40, 93, 169, 1);
    String iconAsset = tipo == 1 ?"assets/icons/advertencia.svg": "assets/icons/check.svg";
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
                    child: tipo == 1? Container(
                      padding: EdgeInsets.only(top:30, bottom: 30),
                      child: SvgPicture.asset(
                        iconAsset,
                        height: 100,
                        color: Colors.white,
                      ),
                    ): 
                    Padding(
                      padding: const EdgeInsets.only(right: 100.0, left: 100, bottom: 30, top: 30),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 40.0, // Cambiado a 40.0 para mantener el radio original
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4.0), // Borde blanco
                          ),
                          child: SvgPicture.asset(
                            iconAsset,
                            color: Colors.white,
                          ),
                        ),
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
                      color: Theme.of(navigatorKey.currentContext!).cardColor, 
                    ),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(fontSize: 16, fontWeight: FontWeight.w500)
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
                            dismiss();
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
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