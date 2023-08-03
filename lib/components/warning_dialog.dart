import 'package:flutter/material.dart';

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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      color: Color.fromARGB(255, 0, 120, 136), // Color para el tipo de alerta 'warning'
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 100.0, left: 100, bottom: 30, top: 30),
                      child: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 59, 59, 59), // Color para el tipo de alerta 'warning'
                        radius: 30.0 + 10.0,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(Icons.warning, color: Color.fromARGB(255, 252, 255, 89), size: 50),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 2, right: 2),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 0, 120, 136)),
                              ),
                              onPressed: () {
                                onOkay();
                                dismiss();
                              },
                              child: Text(
                                'Okay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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