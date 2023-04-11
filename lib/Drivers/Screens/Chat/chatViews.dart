import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/listchat_agents.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
//import 'package:provider/provider.dart';

import '../../../constants.dart';

class ChatPage extends StatefulWidget {
  final String? tripId;

  const ChatPage({Key? key, this.tripId}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> chatUsers = [];

  @override
  void initState() {
    super.initState();
    getCounterNotification(widget.tripId!);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {    
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  void getCounterNotification(String tripId) async {
    final getData = await ChatApis().notificationCounter(widget.tripId!);
    if (getData.isNotEmpty) {
      if (mounted) {
        setState(() {
          chatUsers = getData;
        });
      }
    }
    //print(chatUsers);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.

    Navigator.of(context).pop();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: Text(
          "Agentes del Viaje",
          style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: secondColor),
        ),
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MyAgent()))
          .then((_) => MyAgent());
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getCounterNotification(widget.tripId!);
            },
          )
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // SafeArea(
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 16, right: 16, top: 10),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: <Widget>[
            //         // Padding(
            //         //   padding: const EdgeInsets.symmetric(horizontal: 40.0),
            //         //   child:
            //         // ),
            //         // Container(
            //         //   padding:
            //         //       EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
            //         //   height: 30,
            //         //   decoration: BoxDecoration(
            //         //     borderRadius: BorderRadius.circular(30),
            //         //     color: Colors.pink[50],
            //         //   ),
            //         //   // child: Row(
            //         //   //   children: <Widget>[
            //         //   //     Icon(
            //         //   //       Icons.add,
            //         //   //       color: Colors.pink,
            //         //   //       size: 20,
            //         //   //     ),
            //         //   //     SizedBox(
            //         //   //       width: 2,
            //         //   //     ),
            //         //   //     Text(
            //         //   //       "Add New",
            //         //   //       style: TextStyle(
            //         //   //           fontSize: 14, fontWeight: FontWeight.bold),
            //         //   //     ),
            //         //   //   ],
            //         //   // ),
            //         // )
            //       ],
            //     ),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ConversationList(
                    idAgent: chatUsers[index]['Id'].toString(),
                    nombre: chatUsers[index]['Nombre'],
                    sinLeer_Agente:
                        chatUsers[index]['sinLeer_Agente'].toString(),
                    estado: chatUsers[index]['Estado'],
                    sinleer_Motorista:
                        chatUsers[index]['sinleer_Motorista'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}
