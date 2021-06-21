// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_auth/Drivers/Screens/Details/detailsDriver_Screen.dart';
// import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
// import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
// import 'package:intl/intl.dart';

// import '../../../../constants.dart';

// void main() {
//   runApp(ProcesLeftAgentTrips());
// }

// class ProcesLeftAgentTrips extends StatefulWidget {
//   final PlantillaDriver plantillaDriver;

//   const ProcesLeftAgentTrips({Key key, this.plantillaDriver}) : super(key: key);
//   @override
//   _DataTableExample createState() => _DataTableExample();
// }

// class _DataTableExample extends State<ProcesLeftAgentTrips> {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//           drawer: DriverMenuLateral(),
//           appBar: AppBar(
//             title: Text('Viaje en proceso'),
//             backgroundColor: kColorDriverAppBar,
//             elevation: 0,
//             actions: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                     return DetailsDriverScreen(
//                       plantillaDriver: plantillaDriver[2],
//                     );
//                   }));
//                 },
//               ),
//               SizedBox(width: kDefaultPadding / 2)
//             ],
//           ),
//           body: ListView(children: <Widget>[
//             SizedBox(height: 40.0),
//             Center(
//                 child: Text('Detalles del viaje',
//                     style: TextStyle(
//                         color: Colors.grey[700],
//                         fontWeight: FontWeight.bold,
//                         fontSize: 25.0))),
//             SizedBox(height: 10.0),
//             _tripInProcess(),
//             SizedBox(height: 20.0),
//             Center(
//                 child: Text('Agentes agregados',
//                     style: TextStyle(
//                         color: Colors.grey[700],
//                         fontWeight: FontWeight.normal,
//                         fontSize: 25.0))),
//             SizedBox(height: 10.0),
//             _agentToClimbToDriver(),
//             SizedBox(height: 20.0),
//             _buttonsAgents(),
//             SizedBox(height: 20.0),
//           ])),
//     );
//   } 

//   Widget _tripInProcess() {
//     List cards = new List<Widget>.generate(1, (i)=>new LoopTripInProcess());
//     return Column(
//       children: cards,
//     );
//   }

//   Widget _agentToClimbToDriver() {
//     List cards = new List<Widget>.generate(2, (i)=>new LoopToClimbToDriver());
//     return Column(
//       children: cards,
//     );
//   }


//   Widget _buttonsAgents() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           RaisedButton(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Text(" Completar viaje de salida"),
//             onPressed: () {},
//             color: Colors.green,
//             textColor: Colors.white,
//           ),
//           SizedBox(width: 5),
//           RaisedButton(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             child: Text("Marcar como cancelado"),
//             onPressed: () {},
//             color: Colors.red,
//             textColor: Colors.white,
//           ),
//         ],
//       ),
//     );
//   }


// }

// class LoopTripInProcess extends StatelessWidget {
//   const LoopTripInProcess({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             margin: EdgeInsets.all(15.0),
//             elevation: 2,
//             child: Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ExpansionTile(
//                     backgroundColor: Colors.white,
//                     title: _buildTitle(),
//                     trailing: SizedBox(),
//                     children: [
//                       //aqui lo demás
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.phone,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Teléfono: ',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text('9945-7889'),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.timer,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Entrada:',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text('2:00 P.M.'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Dirección: ',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text(
//                                     '3 casas despues de la tranca, Col. Ideal, \nSan Pedro Sula'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 20.0),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }

//     Widget _buildTitle() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             SizedBox(width: 25.0),
//             Column(
//               children: [
//                 Icon(
//                   Icons.kitchen,
//                   color: Colors.green[500],
//                   size: 35,
//                 ),
//                 Text(' Empresa: ', style: TextStyle(color: Colors.green[500])),
//                 Text('Company', style: TextStyle(color: kTextColor)),
//               ],
//             ),
//             Column(
//               children: [
//                 Icon(
//                   Icons.supervised_user_circle_rounded,
//                   color: Colors.green[500],
//                   size: 35,
//                 ),
//                 Text('Nombre: ', style: TextStyle(color: Colors.green[500])),
//                 Text('Katherine Vanesa', style: TextStyle(color: kTextColor)),
//                 Text('Mejia Lanza', style: TextStyle(color: kTextColor)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

// }

// class LoopToClimbToDriver extends StatefulWidget {
  
//   @override
//   _LoopToClimbToDriverState createState() => _LoopToClimbToDriverState();
// }

// class _LoopToClimbToDriverState extends State<LoopToClimbToDriver> {
//   bool checkBoxValue = false;

//   final format = DateFormat("HH:mm");

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             margin: EdgeInsets.all(15.0),
//             elevation: 2,
//             child: Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ExpansionTile(
//                     backgroundColor: Colors.white,
//                     title: _buildTitle2(),
//                     trailing: SizedBox(),
//                     children: [
//                       //aqui lo demás
//                       Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.phone,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Teléfono: ',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text('9945-7889'),
//                               ],
//                             ),
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.timer,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Entrada:',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text('2:00 P.M.'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Column(
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: Colors.green[500],
//                                   size: 35,
//                                 ),
//                                 Text('Dirección: ',
//                                     style: TextStyle(
//                                         color: Colors.green[500],
//                                         fontSize: 17)),
//                                 Text(
//                                     '3 casas despues de la tranca, Col. Ideal, \nSan Pedro Sula'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: 30.0),
//                       Text('Hora de encuentro: '),
//                       SizedBox(height: 10.0),
//                       _hoursTime(),
//                       SizedBox(height: 20.0),

//                       FlatButton(
//                         onPressed: () {
//                           _observationTrips(context);
//                         },
//                         splashColor: kPrimaryDriverColor,
//                         color: kCardColorDriver2,
//                         child: Text('Observaciones',
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 17)),
//                         textColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                             side: BorderSide(
//                                 color: kCardColorDriver1,
//                                 width: 2,
//                                 style: BorderStyle.solid),
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       SizedBox(height: 20.0),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//   }

//     Widget _hoursTime() {
//     return Container(
//       decoration: BoxDecoration(
//           border: Border.all(width: 1, color: Colors.grey),
//           borderRadius: BorderRadius.all(Radius.circular(4)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               spreadRadius: 5,
//               blurRadius: 7,
//               offset: Offset(0, 3), // changes position of shadow
//             )
//           ]),
//       margin: EdgeInsets.symmetric(horizontal: 40.0),
//       child: Column(
//         children: [
//           DateTimeField(
//             format: format,
//             onShowPicker: (context, currentValue) async {
//               final time = await showTimePicker(
//                 context: context,
//                 initialTime:
//                     TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),                    
//               );
//               return DateTimeField.convert(time);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle2() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Row(
//           children: [
//             Checkbox(
//                 value: checkBoxValue,
//                 onChanged: (bool value) {
//                   setState(() {
//                     checkBoxValue = value;
//                   });
//                 }),
//             Text('Abordó')
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             SizedBox(width: 25.0),
//             Column(
//               children: [
//                 Icon(Icons.kitchen, color: Colors.green[500]),
//                 Text(' Empresa: ', style: TextStyle(color: Colors.green[500])),
//                 Text('Company', style: TextStyle(color: kTextColor)),
//               ],
//             ),
//             Column(
//               children: [
//                 Icon(Icons.supervised_user_circle_rounded,
//                     color: Colors.green[500]),
//                 Text('Nombre: ', style: TextStyle(color: Colors.green[500])),
//                 Text('José Feliciano', style: TextStyle(color: kTextColor)),
//                 Text('Baquedano Carcamo', style: TextStyle(color: kTextColor)),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _observationTrips(BuildContext context) {
//     showGeneralDialog(
//         barrierColor: Colors.black.withOpacity(0.5),
//         transitionBuilder: (context, a1, a2, widget) {
//           return Transform.scale(
//             scale: a1.value,
//             child: Opacity(
//               opacity: a1.value,
//               child: AlertDialog(
//                 shape: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16.0)),
//                 title: Center(
//                     child: Text('¿Razón por la cual no ingresó a la unidad?')),
//                 content: TextField(
//                   decoration: InputDecoration(labelText: 'Escriba aqui'),              
//                 ),
//                 actions: [
//                   Text('Observación...', textAlign: TextAlign.center),
//                   Row(
//                     children: [
//                       SizedBox(width: 60.0),
//                       FlatButton(
//                         onPressed: () => {},
//                         child: Text('Guardar'),
//                         color: kPrimaryDriverColor,
//                         textColor: Colors.white,
//                       ),
//                       SizedBox(width: 10.0),
//                       FlatButton(
//                         onPressed: () => {
//                           Navigator.pop(context),
//                         },
//                         child: Text('Cerrar'),
//                         color: Colors.red,
//                         textColor: Colors.white,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//         transitionDuration: Duration(milliseconds: 200),
//         barrierDismissible: true,
//         barrierLabel: '',
//         context: context,
//         pageBuilder: (context, animation1, animation2) {
//           return null;
//         });
//   }
// }