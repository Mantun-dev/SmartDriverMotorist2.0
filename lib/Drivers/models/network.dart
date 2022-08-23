import 'package:flutter_auth/Drivers/SharePreferences/preferencias_usuario.dart';
import 'package:flutter_auth/Drivers/models/AgentTripCompleted.dart';
import 'package:flutter_auth/Drivers/models/DriverData.dart';
import 'package:flutter_auth/Drivers/models/agentInProgress.dart';

import 'package:flutter_auth/Drivers/models/company.dart';
import 'package:flutter_auth/Drivers/models/countNotify.dart';
import 'package:flutter_auth/Drivers/models/messageDriver.dart';
import 'package:flutter_auth/Drivers/models/profile.dart';

import 'package:flutter_auth/Drivers/models/tripsPendin2.dart';
import 'package:flutter_auth/Drivers/models/tripsPending.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'dart:async';

import 'agentsInTravelModel.dart';


  String ip = "https://driver.smtdriver.com";
  final prefs = new PreferenciasUsuario();

Future<DriverData>fetchRefres() async {
    http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    if (response.statusCode == 200) {       
      return DriverData.fromJson(json.decode(response.body));

    } else {
      throw Exception('Failed to load Data');
    }
}


Future<List< TripsPending2>>fetchTripsPending()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/travelInTrips/${data.driverId}/${prefs.companyId}'));

  var jsonData = json.decode(responses.body);

  List<TripsPending2> trips = [];

  for (var u in jsonData) {
    TripsPending2 trip = TripsPending2(u["tripId"], u["Fecha"], u["Hora"], u["Empresa"], u["Agentes"], u["conductor"]);
    trips.add(trip);
  }
  return trips;

}



Future<List< TripsHistory>>fetchTripsHistory()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/tripsCompleted/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<TripsHistory> trips = [];

  for (var u in jsonData) {
    TripsHistory trip = TripsHistory(u["tripId"], u["Fecha"], u["Hora"], u["Empresa"], u["Agentes"], u['Tipo'], u["conductor"]);
    trips.add(trip);
  }
  return trips;

}

Future< TripsList3>fetchAgentsCompleted()async{

  http.Response responsed = await http.get(Uri.encodeFull('$ip/apis/agentsTripCompleted/${prefs.tripId}'));
  final data1 = TripsList3.fromJson(json.decode(responsed.body));  
    if (responsed.statusCode == 200) {  
      print(data1.trips.length);
      return TripsList3.fromJson(json.decode(responsed.body));      
        
    } else {
      throw Exception('Failed to load Data');
    }


}

var userStatus = List<bool>();
Future< TripsList4>fetchAgentsTripInProgress()async{

  http.Response responsed = await http.get(Uri.encodeFull('$ip/apis/agentsTripInProgress/${prefs.tripId}'));
  final data1 = TripsList4.fromJson(json.decode(responsed.body));  
    if (responsed.statusCode == 200) {  
      print(data1.trips.length);
      userStatus.add(false);
      return TripsList4.fromJson(json.decode(responsed.body));      
        
    } else {
      throw Exception('Failed to load Data');
    }
}



Future<List< TripsInProgress>>fetchTripsInProgress()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/travelInProgressTripsNumberTwo/${data.driverId}/${prefs.companyId}'));

  var jsonData = json.decode(responses.body);

  List<TripsInProgress> trips = [];

  for (var u in jsonData) {
    TripsInProgress trip = TripsInProgress(u["tripId"], u["Fecha"], u["Hora"], u["Empresa"], u["Agentes"], u['Tipo'], u['conductor']);
    trips.add(trip);
  }
  return trips;

}



Future< TripsList2>fetchAgentsInTravel2()async{

  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/travelPendings/${data.driverId}'));
  TripsList.fromJson(json.decode(responses.body));
  http.Response responsed = await http.get(Uri.encodeFull('$ip/apis/agentsInTravel/${prefs.tripId}'));
  TripsList2.fromJson(json.decode(responsed.body));
      
    if (responsed.statusCode == 200) {  
      
      //print(data1.trips[2].cancelados[0].agentFullname);
      return TripsList2.fromJson(json.decode(responsed.body));
      
        
    } else {
      throw Exception('Failed to load Data');
    }

}

Future<List<Company2>>fetchCompanys()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final si = DriverData.fromJson(json.decode(response.body));
  http.Response responsed = await http.get(Uri.encodeFull('$ip/apis/newdeparture/${si.departmentId}'));
    var jsonData = json.decode(responsed.body); 

  List< Company2> trips = [];

  for (var u in jsonData) {
    Company2 trip = Company2(u["companyId"], u["companyName"]);
    trips.add(trip);
  }
  return trips;

}


Future<Profile>fetchRefresProfile() async {
    http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
    final si = DriverData.fromJson(json.decode(response.body));
    http.Response response1 = await http.get(Uri.encodeFull('$ip/apis/score/${si.driverId}'));
    Profile.fromJson(json.decode(response1.body));
    if (response1.statusCode == 200) {   

      return Profile.fromJson(json.decode(response1.body));

    } else {
      throw Exception('Failed to load Data');
    }
}


Future<List< CountNotifications>>fetchCountNotify()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/countTripsProgress/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<CountNotifications> trips = [];

  for (var u in jsonData) {
    CountNotifications trip = CountNotifications(u["total"], u["tripsCreated"], u["tripsInProgress"]);
    trips.add(trip);
  }
  return trips;

}


//ultimo get companies

Future<List< TripsCompanies>>fetchCompaniesGet()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/travelXCompanies/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<TripsCompanies> trips = [];

  for (var u in jsonData) {
    TripsCompanies trip = TripsCompanies(u["trips"], u["companyId"]);
    trips.add(trip);
  }

  return trips;

}

// ultimo Progress Trip
Future<List< TripsCompanies>>fetchProgressTripGet()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/travelInProgressTrips/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<TripsCompanies> trips = [];

  for (var u in jsonData) {
    TripsCompanies trip = TripsCompanies(u["trips"], u["companyId"]);
    trips.add(trip);
  }
  return trips;

}

// drivers 
Future<List< TripsDrivers>>fetchDriversDriver()async{
  http.Response response = await http.get(Uri.encodeFull('$ip/apis/refreshingAgentData/${prefs.nombreUsuario}'));
  final data = DriverData.fromJson(json.decode(response.body));
  http.Response responses = await http.get(Uri.encodeFull('$ip/apis/asigmentDriverToCoord/${data.driverId}'));

  var jsonData = json.decode(responses.body);

  List<TripsDrivers> trips = [];

  for (var u in jsonData) {
    TripsDrivers trip = TripsDrivers(u["driverId"], u["driverDni"],u["driverPhone"], u["driverFullname"],u["driverType"], u["driverStatus"],u["driverPassword"]);
    trips.add(trip);
  }
  return trips;

}

//close session
  Future<Message>fetchDeleteSession() async {
    Map data =
    {
      "token" : prefs.tokenIdMobile
    };
    http.Response response = await http.post(Uri.encodeFull('$ip/apis/deleteTokenSession'), body: data);
    if (response.statusCode == 200) {            
      return Message.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }
