import 'package:flutter/material.dart';

import 'package:flutter_auth/Drivers/Screens/Details/components/travel_In_Trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';

import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';


class AsignarHoras extends StatefulWidget {
  
  final TripsCompanies itemx;
  const AsignarHoras({Key key,  this.itemx}) : super(key: key);

  @override
  _AsignarHorasState createState() => _AsignarHorasState();
}

class _AsignarHorasState extends State<AsignarHoras> {
  Future<List< TripsCompanies>> itemx;
  TextEditingController companyId = new TextEditingController();
  final prefs = new PreferenciasUsuario();
  String ip = "https://driver.smtdriver.com";
  
  @override
  void initState() { 
    super.initState();    
    itemx = fetchCompaniesGet();    
    companyId = new TextEditingController( text: prefs.companyId );
  }


fetchTravelInTrip(String companyId){
  prefs.companyId = companyId;
  if (companyId == companyId) {
    Navigator.push(context,MaterialPageRoute(builder: (context) => Trips(),));      
  }
}

  @override
  Widget build(BuildContext context) {
        return Container(
            width: 500.0,
            child: Column(
              children: [
                FutureBuilder<List< TripsCompanies>>(
                future: itemx,
                builder: (BuildContext context, abc) {
                  if (abc.connectionState == ConnectionState.done) {
                    if (abc.data.length < 1) {
                      return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.bus_alert),
                                title: Text('Agentes', style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 26.0)),
                                subtitle: Text('No hay viajes pendientes', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18.0)),
                              ),                      
                            ],
                          ),
                        );
                    } else {
                      return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: abc.data.length,
                      itemBuilder: (context, index){  
                          return InkWell(
                            onTap: (){                                                                                                
                              fetchTravelInTrip(abc.data[index].companyId.toString());
                            },
                            child: Card(
                              color: Colors.white,
                              shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.all(12),
                              elevation: 10,
                              child: Column(
                                children: <Widget>[
                                    SizedBox(height: 20.0),                              
                                    Container(                                                                     
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [                                          
                                          Container(                                      
                                          height: 80,
                                          width: 170,
                                          child: Column(
                                              children: [
                                                if (abc.data[index].companyId == 1)... {
                                                  Container(                                                    
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/destination.png'),                                          
                                                  ),
                                                },
                                                if (abc.data[index].companyId == 2 || abc.data[index].companyId == 3)... {
                                                  Container(
                                                    
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/startek.webp'),                                          
                                                  ),
                                                },
                                                if (abc.data[index].companyId == 6)... {
                                                  Container(
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/Alorica_Logo.png'),                                          
                                                  ),
                                                },
                                                if (abc.data[index].companyId == 7)... {
                                                  Container(                                                    
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/zero.png'),                                          
                                                  ),
                                                }, 
                                                if (abc.data[index].companyId == 8)... {
                                                  Container(                                                    
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/emerge-bpo-largex5-logo.png'),                                          
                                                  ),
                                                }else...{
                                                  Container(                                                    
                                                    height: 80,
                                                    width: 170,
                                                    child: Image.asset('assets/images/destination.png'),                                          
                                                  ),
                                                }, 
                                                                                              
                                              ],
                                          ),   
                                        ), 
                                          // Column(
                                          //   children: [
                                          //     Icon(
                                          //       Icons.account_balance,
                                          //       color: Colors.green[500],
                                          //       size: 35,
                                          //     ),
                                          //     Text('Compañia: ',
                                          //         style: TextStyle(
                                          //             color: Colors.green[500], fontSize: 17)),
                                          //     if (abc.data[index].companyId == 1)... {
                                          //       Text('Compañia de prueba'),                                            
                                          //     },  
                                          //     if (abc.data[index].companyId == 2)... {
                                          //       Text('Startek SPS'),                                            
                                          //     }, 
                                          //     if (abc.data[index].companyId == 3)... {
                                          //       Text('Startek TGU'),                                            
                                          //     },   
                                          //     if (abc.data[index].companyId == 6)... {
                                          //       Text('Alorica SPS'),                                            
                                          //     },       
                                          //     if (abc.data[index].companyId == 7)... {
                                          //       Text('Zero variance SPS'),                                            
                                          //     }, 
                                          //   ],
                                          // ),
                                        Container(                
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          margin: EdgeInsets.only(bottom: 25),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                          child: Text('${abc.data[index].trips}', style: TextStyle(color: Colors.white, fontSize: 13),
                                          )
                                        ),
                                          // Flexible(
                                          //   child: Column(
                                          //     children: [
                                          //       Icon(
                                          //         Icons.tag,
                                          //         color: Colors.green[500],
                                          //         size: 35,
                                          //       ),
                                          //       Text('Viajes: ',
                                          //           style: TextStyle(
                                          //               color: Colors.green[500], fontSize: 17)),
                                          //       Text('${abc.data[index].trips}'),
                                          //     ],
                                          //   ),
                                          // ),
                                          
                                        ],
                                      ),
                                    ),
                                   
                                   SizedBox(height: 20.0),                                                              
                                ],
                              ),
                                                  ),
                          );                        
                      }
                    );              
                    
                    }

                  } else {
                    return ColorLoader3();
                  }
                  
                },
              )
              ],
            
            ),
          );                  
  
  }
}

