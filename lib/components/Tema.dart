import 'package:flutter/material.dart';

const familyFont = 'Roboto';

final ThemeData appThemeDataLight = ThemeData(
  fontFamily: familyFont,

  primaryColor: const Color.fromRGBO(40, 93, 169, 1),
  scaffoldBackgroundColor:const Color.fromRGBO(248, 248, 248, 1),

  primaryColorLight: Colors.white,
  primaryColorDark: Colors.black,

  cardColor: Colors.white,
  hintColor: const Color.fromRGBO(158, 158, 158, 1),
  focusColor: const Color.fromRGBO(40, 93, 169, 1),
  hoverColor: Color(0xffc32c37),
  highlightColor: Colors.transparent,

  disabledColor: Color.fromRGBO(238, 238, 238, 1),
  dividerColor: Color.fromRGBO(158, 158, 158, 1),
  splashColor: Color.fromRGBO(158, 158, 158, 1),

  shadowColor: Color.fromRGBO(158, 158, 158, 0.18),

  canvasColor: Color.fromRGBO(236, 235, 235, 1),

  appBarTheme: AppBarTheme(backgroundColor: Colors.white),

  cardTheme: CardTheme(color: Color.fromRGBO(241, 239, 239, 1)),

  primaryIconTheme: IconThemeData(color: const Color.fromRGBO(40, 93, 169, 1)),



  textTheme: const TextTheme(

    labelSmall: TextStyle( 
      color: Colors.black,
      fontSize: 9,
      fontFamily: familyFont,
      fontWeight: FontWeight.normal
    ),

    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: familyFont,
      fontWeight: FontWeight.normal
    ),

    titleMedium: TextStyle(
      color: Colors.black,
      fontFamily: familyFont,
      fontWeight: FontWeight.bold
    ),

    bodyMedium: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontFamily: familyFont,
    ),

    bodySmall: TextStyle(
      color: Color.fromRGBO(158, 158, 158, 1),
      fontWeight: FontWeight.normal,
      fontFamily: familyFont,
    ),

    labelMedium: TextStyle(
      color: Color.fromRGBO(40, 93, 169, 1),
      fontWeight: FontWeight.bold,
      fontFamily: familyFont,
    ),

    titleSmall: TextStyle(
      color: Colors.black,
      fontFamily: familyFont,
      fontWeight: FontWeight.w500
    ),

  ),
);


final ThemeData appThemeDataDark = ThemeData(

  fontFamily: familyFont,

  primaryColor: const Color.fromRGBO(27, 27, 39, 1),
  scaffoldBackgroundColor:const Color.fromRGBO(14, 14, 20, 1),

  primaryColorLight: Colors.black,
  primaryColorDark: Colors.white,

  cardColor: Color.fromRGBO(47, 46, 65, 1),
  hintColor: Colors.white,
  focusColor: const Color.fromRGBO(40, 93, 169, 1),
  hoverColor: Colors.white,

  disabledColor: Color.fromRGBO(68, 67, 82,1),
  dividerColor: Color.fromRGBO(158, 158, 158, 1),
  splashColor: Color.fromRGBO(158, 158, 158, 1),

  highlightColor: Colors.white,

  shadowColor: Color.fromRGBO(158, 158, 158, 0.18),

  appBarTheme: AppBarTheme(backgroundColor: const Color.fromRGBO(27, 27, 39, 1)),

  cardTheme: CardTheme(color: Color.fromRGBO(158, 158, 158, 0.18)),

  canvasColor: Color.fromRGBO(35, 35, 46, 1),

  primaryIconTheme: IconThemeData(color: Colors.white,),

  textTheme: const TextTheme(

    labelSmall: TextStyle( 
      color: Colors.white,
      fontSize: 9,
      fontFamily: familyFont,
      fontWeight: FontWeight.normal
    ),

    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: familyFont,
      fontWeight: FontWeight.normal
    ),

    titleMedium: TextStyle(
      color: Colors.white,
      fontFamily: familyFont,
      fontWeight: FontWeight.bold
    ),

    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.normal
    ),

    bodySmall: TextStyle(
      color: Color.fromRGBO(158, 158, 158, 1),
      fontWeight: FontWeight.normal,
      fontFamily: familyFont,
    ),

    labelMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: familyFont,
      
    ),

    titleSmall: TextStyle(
      color: Colors.white,
      fontFamily: familyFont,
      fontWeight: FontWeight.w500
    ),

  ),
  
);