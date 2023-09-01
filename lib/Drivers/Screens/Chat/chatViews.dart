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
  bool confirmados = true;
  bool noconfirmados = false;
  bool cancelados = false;

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

  Widget opcionesBotones() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),

                elevation: 0,
                backgroundColor: confirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  Text('Confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: confirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                
                  SizedBox(width: 5),
                  
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: confirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '0',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: confirmados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              onPressed: confirmados==true?null:() {
                setState(() {
                  confirmados = true;
                  noconfirmados = false;
                  cancelados = false;
                });
              },
            ),
    
            Padding(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: TextButton(
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                  elevation: 0,
                  backgroundColor: noconfirmados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Text('No confirmados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: noconfirmados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  
                    SizedBox(width: 5),
                    
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: noconfirmados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '0',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: noconfirmados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
                onPressed: noconfirmados==true?null:() {
                  setState(() {
                    confirmados = false;
                    noconfirmados = true;
                    cancelados = false;
                  });
                },
              ),
            ),
    
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(width: 1, color: Theme.of(context).primaryColorDark),
                elevation: 0,
                backgroundColor: cancelados!=true?Colors.transparent:Theme.of(context).primaryColorDark,
                shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Text('Cancelados',style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: cancelados==true?Theme.of(context).primaryColorLight:Theme.of(context).primaryColorDark)),
                  
                    SizedBox(width: 5),
                    
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cancelados == false ? Theme.of(context).unselectedWidgetColor : Theme.of(context).primaryColorLight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '0',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: cancelados == false ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              onPressed: cancelados==true?null:() {
                setState(() {
                  confirmados = false;
                  noconfirmados = false;
                  cancelados = true;
                });
              },
            ),
          ],
        ),
    );
  }

  SingleChildScrollView body() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          opcionesBotones(),
          SizedBox(height: 10.0),
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
                      getCounterNotification(widget.tripId!);
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
              print(chatUsers);
              return Container(
                child: Column(
                  children: [
                    if(confirmados==true)...{
                      if(chatUsers[index]['Estado'] == 'CONFIRMADO')...{
                        Text('${chatUsers[index]['Nombre']}'),
                        Text('${chatUsers[index]['Id']}'),
                      }
                    }else if(cancelados==true)...{
                      if(chatUsers[index]['Estado'] == 'RECHAZADO')...{
                        Text('${chatUsers[index]['Nombre']}'),
                        Text('${chatUsers[index]['Id']}'),
                      }
                    }else...{
                      if(chatUsers[index]['Estado'] != 'RECHAZADO' && chatUsers[index]['Estado'] != 'CONFIRMADO')...{
                        Text('${chatUsers[index]['Nombre']}'),
                        Text('${chatUsers[index]['Id']}'),
                      }
                    }
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
