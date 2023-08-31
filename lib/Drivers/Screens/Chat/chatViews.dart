import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/chatapis.dart';
import 'package:flutter_auth/Drivers/Screens/Chat/listchat_agents.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
import 'package:flutter_auth/main.dart';
//import 'package:flutter_auth/Drivers/Screens/Details/components/agents_Trip.dart';
//import 'package:provider/provider.dart';

import '../../../components/AppBarPosterior.dart';
import '../../../components/AppBarSuperior.dart';
import '../../../components/backgroundB.dart';
import '../../../constants.dart';
import '../Details/components/confirm_trips.dart';

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
    Size size = MediaQuery.of(context).size;
    return BackgroundBody(
      child: Scaffold(
        backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: AppBarSuperior(item: 66)
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 700.0, // Aquí defines el ancho máximo deseado
                          ),
                          child: SingleChildScrollView(child: body()),
                        ),
                      )
                    ),
                    SafeArea(child: AppBarPosterior(item:3)),
                  ],
                ),
              ),
    );
  }

  SingleChildScrollView body() {
    return SingleChildScrollView(
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
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Theme.of(context).disabledColor)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged:(value) {

                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
                        hintText: 'Buscar',
                        hintStyle: TextStyle(
                            color: Theme.of(context).hintColor, fontSize: 15, fontFamily: 'Roboto'
                          ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: Icon(Icons.refresh),
                    color: Theme.of(context).primaryIconTheme.color,
                    onPressed: () {
                      //refresh();
                    },
                  )
                ],
              )
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
    );
  }
}
