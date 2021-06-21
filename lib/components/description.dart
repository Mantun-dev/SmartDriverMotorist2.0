// import 'package:flutter/material.dart';
// import 'package:flutter_auth/Drivers/Screens/Details/components/historyTrip.dart';
// import 'package:flutter_auth/Agents/Screens/Details/components/next_trip.dart';
// import 'package:flutter_auth/Agents/Screens/Details/components/qr_Screen.dart';
// import 'package:flutter_auth/Agents/Screens/Details/components/tickets.dart';
// import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';

// class Description extends StatelessWidget {
//   const Description({
//     Key key,
//     @required this.plantilla,
//   }) : super(key: key);

//   final PlantillaDriver plantilla;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Column(
//         children: [
//           _processCards(context),
//         ],
//       ),
//     );
//   }

//   //aquí llamo cada una de las páginas que contendran la in información
//   Widget _processCards(BuildContext context) {
//     return Column(
//       children: [
//         if (plantilla.id == 1) ...[
//           _mostrarPrimerventana(),
//           SizedBox(height: 50),
//         ] else if (plantilla.id == 2) ...[
//           _mostrarSegundaVentana(),
//           SizedBox(height: 50.0),
//         ] else if (plantilla.id == 3) ...[
//           _mostrarTerceraVentana(),
//           SizedBox(height: 100.0),
//         ] else if (plantilla.id == 4) ...[
//           _mostrarCuartaVentana(),
//           SizedBox(height: 20.0),
//         ]
//       ],
//     );
//   }

//   Widget _mostrarPrimerventana() {
//     return NextTripScreen();
//   }

//   Widget _mostrarSegundaVentana() {
//     return HistoryTripScreen();
//   }

//   Widget _mostrarTerceraVentana() {
//     return TicketScreen();
//   }

//   Widget _mostrarCuartaVentana() {
//     return QrScannScreen();
//   }
// }
