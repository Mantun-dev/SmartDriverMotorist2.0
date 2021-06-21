// import 'package:flutter/material.dart';
// import 'package:flutter_auth/Agents/Screens/Details/details_screen.dart';
// import 'package:flutter_auth/Agents/Screens/Profile/profile_screen.dart';
// import 'package:flutter_auth/Drivers/Screens/Welcome/welcome_screen.dart';
// import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';

// class MenuLateral extends StatelessWidget {
//   const MenuLateral({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: [
//           UserAccountsDrawerHeader(
//             accountName:
//                 Text('Aqui se va introducur el nombre de usuario en la Api'),
//             accountEmail: Text('Aqui se introduce el correo del usuario'),
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: NetworkImage(
//                         'https://hipertextual.com/files/2017/03/color-degradado-fondos-degradados-multicolor-51200.jpg'),
//                     fit: BoxFit.cover)),
//           ),
//           ListTile(
//             title: Text('Mi perfil'),
//             leading: Icon(Icons.account_circle),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return ProfilePage();
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text('Mis proximos viajes'),
//             leading: Icon(Icons.airport_shuttle),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return DetailScreen(plantilla: plantillaDriver[0]);
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text('Historial de viajes'),
//             leading: Icon(Icons.history),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return DetailScreen(plantilla: plantillaDriver[1]);
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text('Solicitud de cambios'),
//             leading: Icon(Icons.outbox),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return DetailScreen(plantilla: plantillaDriver[2]);
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text('Generar codigo qr'),
//             leading: Icon(Icons.qr_code),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return DetailScreen(plantilla: plantillaDriver[3]);
//               }));
//             },
//           ),
//           Divider(),
//           ListTile(
//             title: Text('Cerrar sesión'),
//             leading: Icon(Icons.logout),
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) {
//                 return WelcomeScreen();
//               }));
//             },
//           ),
//           Divider()
//         ],
//       ),
//     );
//   }
// }
