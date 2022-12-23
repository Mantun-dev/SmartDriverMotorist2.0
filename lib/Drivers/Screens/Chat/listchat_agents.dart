import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatscreen.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/constants.dart';

// ignore: must_be_immutable
class ConversationList extends StatefulWidget {
  String nombre;

  // ignore: non_constant_identifier_names
  String sinLeer_Agente;
  String estado;
  // ignore: non_constant_identifier_names
  String sinleer_Motorista;
  String idAgent;
  ConversationList({
    Key? key,
    required this.nombre,
    // ignore: non_constant_identifier_names
    required this.sinLeer_Agente,
    required this.estado,
    // ignore: non_constant_identifier_names
    required this.sinleer_Motorista,
    required this.idAgent,
  }) : super(key: key);
  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        fetchRefresProfile().then((value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        idAgent: widget.idAgent.toString(),
                        nombreAgent: widget.nombre,
                        nombre: "${value.driver!.driverFullname}",
                        id: "${value.driver!.driverId}",
                        rol: "MOTORISTA",
                      )));
        });
        print(prefs.driverIdx);
      },
      child: Container(
        color: backgroundColor2,
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  // CircleAvatar(
                  //   backgroundImage: NetworkImage(widget.imageUrl),
                  //   maxRadius: 30,
                  // ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.nombre,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: firstColor),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.sinleer_Motorista != "0"
                                    ? "Nuevo mensaje"
                                    : "Sin Mensajes",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade200,
                                    fontWeight: widget.sinleer_Motorista != "0"
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.sinleer_Motorista != "0"
                                    ? "${widget.sinleer_Motorista}"
                                    : "0",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: thirdColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.estado,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Gradiant2),
            ),
          ],
        ),
      ),
    );
  }
}
