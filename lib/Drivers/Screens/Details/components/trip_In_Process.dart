import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/Details/components/confirm_trips.dart';
import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';

import 'package:flutter_svg/svg.dart';


import '../../../../components/AppBarPosterior.dart';
import '../../../../components/AppBarSuperior.dart';
import '../../../../components/backgroundB.dart';
import '../../../../components/warning_dialog.dart';

void main() => runApp(Process());

class Process extends StatefulWidget {
  final TripsInProgress? item;
  const Process({Key? key, this.item}) : super(key: key);
  @override
  _ProcessState createState() => _ProcessState();
}

class _ProcessState extends State<Process> {
  Future<List<TripsInProgress>>? item;
  TextEditingController tripId = new TextEditingController();
  final prefs = new PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    item = fetchTripsInProgress();
    tripId = new TextEditingController(text: prefs.tripId);
  }

  fetchAgentsAsigmentChekc(String tripId, int departamentoId, departamentoNombre) async {
    prefs.tripId = tripId;

    if (tripId == tripId) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyConfirmAgent(departmentId: departamentoId, departmentName: departamentoNombre,),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BackgroundBody(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(56),
                    child: AppBarSuperior(item: 22,)
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: SingleChildScrollView(child: body(size))),
                      ),
                      SafeArea(child: AppBarPosterior(item:-1)),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget body(Size size) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder<List<TripsInProgress>>(
        future: item,
        builder: (BuildContext context, abc) {
          if (abc.connectionState == ConnectionState.done) {
            if (abc.data!.length < 1) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15,bottom: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,  
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset( 
                            "assets/icons/advertencia.svg",
                            color: Theme.of(context).primaryIconTheme.color,
                            width: 18,
                            height: 18,
                          ),
                          Flexible(
                            child: Text(
                              '  No hay viajes pendientes',
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15, color: Color.fromRGBO(213, 0, 0, 1), fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: abc.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Theme.of(context).dividerColor,),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20),
                          child: Column(
                            children:[
    
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [ 
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/Numeral.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Viaje: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].tripId}',
                                              style: TextStyle(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
    
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/calendar2.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Fecha: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].fecha}',
                                              style: TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
    
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/compania.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Empresa: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].empresa}',
                                              style: TextStyle(fontWeight: FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
    
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/hora.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Hora: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].hora}',
                                              style: TextStyle(fontWeight: FontWeight.w700, color: Color.fromRGBO(40, 169, 83, 1)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
                              
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/agentes.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Agentes: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].agentes}',
                                              style: TextStyle(fontWeight: FontWeight.w700,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
    
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(right: 5, left: 10, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      child: SvgPicture.asset(
                                        "assets/icons/advertencia.svg",
                                        color: Theme.of(context).primaryIconTheme.color,
                                      ),
                                    ),
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 15),
                                          children: [
                                            TextSpan(
                                              text: '  Tipo: ',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            TextSpan(
                                              text: '${abc.data![index].tipo}',
                                              style: TextStyle(fontWeight: FontWeight.normal,),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],

                                ),
                              ),
                              Container(
                                height: 1,
                                color: Theme.of(context).dividerColor,
                              ),
    
                              SizedBox(height: 15),
                              TextButton(
                                style: TextButton.styleFrom(
                                  fixedSize: Size(150, 25),
                                  elevation: 0,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                ),
                                child: Text('Ver viaje',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontSize: 16)),
                                  onPressed: () {                                           
                                    fetchAgentsAsigmentChekc(abc
                                        .data![index].tripId
                                        .toString(),
                                        abc.data![index].departmentId,
                                        abc.data![index].departamento
                                        );
                                        if(abc.data![index].tipo=='Entrada')
                                          WarningSuccessDialog().show(
                                                context,
                                                title: "No olvide escanear el código QR del agente antes de que suba a la unidad para que podamos guardar la ubicación del punto de encuentro. Este mensaje se mostrará hasta guardar los puntos de encuentro.",
                                                tipo: 4,
                                                onOkay: () {},
                                              );
                                  },
                                ),
                                SizedBox(height: 10.0),                                      
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          } else {
            return WillPopScope(
                  onWillPop: () async => false,
                  child: SimpleDialog(
                    elevation: 20,
                    backgroundColor: Theme.of(context).cardColor,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                              child: CircularProgressIndicator(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Cargando...', 
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
                                ),
                            )
                          ],
                        ),
                      )
                    ] ,
                  ),
                );
          }
        },
      ),
    );
  }
}