import 'package:flutter/material.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/components/driverBackground.dart';
import 'package:flutter_auth/Drivers/Screens/HomeDriver/homeScreen_Driver.dart';
import 'package:flutter_auth/Drivers/components/loader.dart';
import 'package:flutter_auth/Drivers/components/menu_lateralDriver.dart';
import 'package:flutter_auth/Drivers/models/network.dart';
import 'package:flutter_auth/Drivers/models/plantillaDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';

import '../../../constants.dart';

void main() {
  runApp(DriverProfilePage());
}

class DriverProfilePage extends StatefulWidget {
  final PlantillaDriver plantillaDriver;
  final Profile item;

  const DriverProfilePage({Key key, this.plantillaDriver, this.item}) : super(key: key);
  @override
  _DataTableExample createState() => _DataTableExample();
}

class _DataTableExample extends State<DriverProfilePage> {
  Future < Profile>item;
  final si = 0.0;
    @override
    void initState() { 
      super.initState();
      item = fetchRefresProfile();
    }
    
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          drawer: DriverMenuLateral(),
          appBar: AppBar(
            title: Center(
              child: Text(
                'Información General',
              ),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {                 
                  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>
                  HomeDriverScreen()),(Route<dynamic> route) =>false);
                },
              ),
              SizedBox(width: kDefaultPadding / 2)
            ],
            backgroundColor: kColorDriverAppBar,
            elevation: 0,
          ),
          body: DriverBackground(
            child: ListView(children: <Widget>[
              SizedBox(height: 20.0),
              FutureBuilder<Profile>(
                future: item,
                  builder: (BuildContext context, abc) {
                    if (abc.connectionState == ConnectionState.done) {                      
                    return  Column(
                      children: [
                        SingleChildScrollView(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.all(15),
                          elevation: 10,
                          child: Column(
                            children: [

                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                //color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 15.0),
                              width: 500,
                              height: 220,
                              child: DataTable(columns: [
                                DataColumn(
                                    label: Text('Datos',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: kCardColorDriver2))),
                              ], rows: [
                                DataRow(cells: [
                                  DataCell(Text('Indentidad: ${abc.data.driver.driverDni}',
                                      style: TextStyle(color: kgray))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Nombre: ${abc.data.driver.driverFullname}',
                                      style: TextStyle(color: kgray))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Teléfono: ${abc.data.driver.driverPhone}',
                                      style: TextStyle(color: kgray))),
                                ]),
                              ]),
                            ),
                            Divider(),
                            Text('Puntuación',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: kCardColorDriver2)),
                            RatingBarIndicator(
                                rating: abc.data.rating["driverRating"],
                                itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 40.0,
                                direction: Axis.horizontal,
                            ),
                            SizedBox(height: 10.0),
                            Text('${abc.data.rating["driverRating"]} de promedio basado en ${abc.data.rating["totalReviews"]} opiniones.',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.grey)),
                            SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ),   
                      if (abc.data.percentageBars1.stars5 == null || abc.data.percentageBars2.stars5 == null || abc.data.percentageBars3.stars5 == null)... {
                         Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.symmetric(vertical: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.bus_alert),
                                title: Text('Calificación', style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20.0)),
                                subtitle: Text('Aún no ha sido calificado', style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15.0)),
                              ),                      
                            ],
                          ),
                        )
                      } else... {
                        Card(
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.all(15),
                          elevation: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              //color: Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 15.0),
                            width: 500,
                            height: 950,
                            child: Column(children: [
                              SizedBox(height: 10.0),
                              Text('Conducción',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: kCardColorDriver2)),
                              SizedBox(height: 10.0),
                              Text('5 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["five1"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars1.stars5.toDouble()==null?si:abc.data.percentageBars1.stars5.toDouble(),height: 20,theme: RoundedProgressBarTheme.blue),
                              Text('4 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["four1"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars1.stars4.toDouble()==null?si:abc.data.percentageBars1.stars4.toDouble(),height: 20,theme: RoundedProgressBarTheme.green),
                              Text('3 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["three1"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars1.stars3.toDouble()==null?si:abc.data.percentageBars1.stars3.toDouble(),height: 20,theme: RoundedProgressBarTheme.purple),
                              Text('2 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["two1"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars1.stars2.toDouble()==null?si:abc.data.percentageBars1.stars2.toDouble(),height: 20,theme: RoundedProgressBarTheme.yellow),
                              Text('1 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["one1"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars1.stars1.toDouble()==null?si:abc.data.percentageBars1.stars1.toDouble(),height: 20,theme: RoundedProgressBarTheme.red),
                              Divider(),
                              SizedBox(height: 30.0),
                              Text('Amabilidad',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: kCardColorDriver2)),                              
                              SizedBox(height: 10.0),
                              Text('5 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["five2"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars2.stars5.toDouble()==null?si:abc.data.percentageBars2.stars5.toDouble(),height: 20,theme: RoundedProgressBarTheme.blue),
                              Text('4 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["four2"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars2.stars4.toDouble()==null?si:abc.data.percentageBars2.stars4.toDouble(),height: 20,theme: RoundedProgressBarTheme.green),
                              Text('3 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["three2"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars2.stars3.toDouble()==null?si:abc.data.percentageBars2.stars3.toDouble(),height: 20,theme: RoundedProgressBarTheme.purple),
                              Text('2 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["two2"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars2.stars2.toDouble()==null?si:abc.data.percentageBars2.stars2.toDouble(),height: 20,theme: RoundedProgressBarTheme.yellow),
                              Text('1 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["one2"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars2.stars1.toDouble()==null?si:abc.data.percentageBars2.stars1.toDouble(),height: 20,theme: RoundedProgressBarTheme.red),
                              Divider(),
                              SizedBox(height: 30.0),
                              Text('Condiciones del vehículo',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: kCardColorDriver2)),
                              SizedBox(height: 10.0),
                              Text('5 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["five3"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars3.stars5.toDouble()==null?si:abc.data.percentageBars3.stars5.toDouble(),height: 20,theme: RoundedProgressBarTheme.blue),
                              Text('4 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["four3"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars3.stars4.toDouble()==null?si:abc.data.percentageBars3.stars4.toDouble(),height: 20,theme: RoundedProgressBarTheme.green),
                              Text('3 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["three3"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars3.stars3.toDouble()==null?si:abc.data.percentageBars3.stars3.toDouble(),height: 20,theme: RoundedProgressBarTheme.purple),
                              Text('2 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["two3"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars3.stars2.toDouble()==null?si:abc.data.percentageBars3.stars2.toDouble(),height: 20,theme: RoundedProgressBarTheme.yellow),
                              Text('1 Estrellas',style: TextStyle(color: kgray)),
                              RoundedProgressBar(childCenter: Text("${abc.data.rating["one3"].toInt()} ",style: TextStyle(color: Colors.white, fontSize: 10)),percent: abc.data.percentageBars3.stars1.toDouble()==null?si:abc.data.percentageBars3.stars1.toDouble(),height: 20,theme: RoundedProgressBarTheme.red),
                            ],),
                          ),
                        ),
                   
                           
                      }
                          
                      
                        ],
                      );
                     
                    }else{
                      return ColorLoader3();
                    }
                  },
                ),
              
            ]),
          )),
    );
  }
}
