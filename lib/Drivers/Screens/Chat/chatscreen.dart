import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';

import 'package:flutter_auth/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../helpers/base_client.dart';
import '../../../helpers/res_apis.dart';
import '../../../providers/chat.dart';
import '../../models/message_chat.dart';
import '../Details/components/agents_Trip.dart';
import '../DriverProfile/driverProfile.dart';

import 'socketChat.dart';

class ChatScreen extends StatefulWidget {
  final String nombre;
  final String id;
  final String rol;
  const ChatScreen({Key key, this.nombre, this.id, this.rol}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final _socketResponse = StreamController<dynamic>();
  // Stream<dynamic> get getResponse => _socketResponse.stream;
  IO.Socket socket;
  final TextEditingController _messageInputController = TextEditingController();
  var usuario = {};
  var arrayStructure = [];
  var idE;
  var idR;
  String sala;
  String id;
  String idDb;
  String nameDriver;
  String nameAgent;
  ScrollController _scrollController = new ScrollController();
  final arrayTemp = [];
  final StreamSocket streamSocket = StreamSocket(host: '0sufv.localtonet.com');

  _sendMessage() {
    ChatApis().sendMessage(_messageInputController.text.trim(), sala.toString(),
        widget.nombre, id.toString(), nameAgent, idDb, idE, idR);
    //ChatApis().rendV(modid, sala);
    _messageInputController.clear();
  }

  @override
  void initState() {
    super.initState();

    datas();
    scroll();
    //inicializador del botón de android para manejarlo manual
    BackButtonInterceptor.add(myInterceptor);
  }

  void getMessages(String idE, String idR, String sala) async {
    final response = await BaseClient().get(
        RestApis.messages + "/$sala" + "/$idE" + "/$idR",
        {"Content-Type": "application/json"});

    if (response == null) return null;
    final data = jsonDecode(response);
    Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();

    data["listM"].forEach((element) {
      arrayStructure.add({
        "mensaje": element["Mensaje"],
        "sala": element["Sala"],
        "user": element["Nombre_emisor"],
        "id": element["id_emisor"],
        "hora": element["Hora"],
        "dia": element["Dia"],
        "mes": element["Mes"],
        "año": element["Año"],
        "tipo": element["Tipo"]
      });
    });
    arrayStructure.forEach((result) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false)
            .addNewMessage(MessageDriver.fromJson(result));
      }
    });
  }

  void datas() {
    ChatApis().dataLogin(widget.id, widget.rol, widget.nombre);
    streamSocket.socket.on('detectarE', (data) => print(data));
    streamSocket.socket.on('entrarChat_flutter', (data) {
      ChatApis().setTarget();
      setState(() {
        sala = data["Usuarios"]["target"]['sala'].toString();
        id = data["Usuarios"]["target"]['id'].toString();
        idDb = data["Usuarios"]["target"]['_id'].toString();
        //nameDriver = data["Usuarios"]["target"]['nombre'];
        nameAgent = data["Usuarios"]["target"]['nombre'];
      });
      Provider.of<ChatProvider>(context, listen: false).mensaje2.clear();
      data['listM'].forEach((value) {
        print(value);
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(value));
        }
      });
      ChatApis().readMessage(data);
    });

    streamSocket.socket.on(
      'flutter-mensaje',
      ((data) {
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(data));
        }
      }),
    );

    streamSocket.socket.on(
      'enviar-mensaje',
      ((data) {
        if (mounted) {
          Provider.of<ChatProvider>(context, listen: false)
              .addNewMessage(MessageDriver.fromJson(data));
        }
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _messageInputController.dispose();

    //creación del dispose para removerlo después del evento
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    streamSocket.socket.disconnect();
    streamSocket.socket.close();
    streamSocket.socket.dispose();

    print(streamSocket.socket.connected);

    //Navigator.of(context).pop();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyAgent()));

    return true;
  }

  void scroll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: nameAgent == null
            ? Text("")
            : Text(
                nameAgent,
                style: TextStyle(color: thirdColor),
              ),
        backgroundColor: backgroundColor,
        shadowColor: Colors.black87,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: secondColor,
          ),
          onPressed: () {
            streamSocket.socket.disconnect();
            streamSocket.socket.close();
            streamSocket.socket.dispose();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyAgent()));
          },
        ),
        elevation: 10,
        iconTheme: IconThemeData(color: secondColor, size: 35),
        actions: <Widget>[
          //aquí está el icono de las notificaciones
          IconButton(
            icon: Icon(
              Icons.message,
              size: 35,
              color: firstColor,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DriverProfilePage();
              }));
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/user.svg",
              width: 100,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DriverProfilePage();
              }));
            },
          ),
          SizedBox(width: kDefaultPadding / 2)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) => ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final message = provider.mensaje[index];
                  print(provider.mensaje2.length);
                  return Wrap(
                    alignment: message.user == widget.nombre
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.user == widget.nombre
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: message.user == widget.nombre
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (message.mensaje != null) ...{
                                Text(message.mensaje),
                              },
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    message.hora,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    message.leido == true
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 15,
                                    color: message.leido == true
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: provider.mensaje.length,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje aqui...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
