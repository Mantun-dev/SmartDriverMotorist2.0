// To parse this JSON data, do
//
//     final agentInTripsPending = agentInTripsPendingFromJson(jsonString);

import 'dart:convert';

List<AgentInTripsPending> agentInTripsPendingFromJson(String str) => List<AgentInTripsPending>.from(json.decode(str).map((x) => AgentInTripsPending.fromJson(x)));

String agentInTripsPendingToJson(List<AgentInTripsPending> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AgentInTripsPending {
    AgentInTripsPending({
        this.agentes,
        this.noConfirmados,
        this.cancelados,
        this.viajeActual,
    });

    List<Agente>? agentes;
    List<Agente>? noConfirmados;
    List<Agente>? cancelados;
    ViajeActual ?viajeActual;

    factory AgentInTripsPending.fromJson(Map<String, dynamic> json) => AgentInTripsPending(
        agentes: json["agentes"] == null ? null : List<Agente>.from(json["agentes"].map((x) => Agente.fromJson(x))),
        noConfirmados: json["noConfirmados"] == null ? null : List<Agente>.from(json["noConfirmados"].map((x) => Agente.fromJson(x))),
        cancelados: json["cancelados"] == null ? null : List<Agente>.from(json["cancelados"].map((x) => Agente.fromJson(x))),
        viajeActual: json["viajeActual"] == null ? null : ViajeActual.fromJson(json["viajeActual"]),
    );

    Map<String, dynamic> toJson() => {
        "agentes": agentes == null ? null : List<dynamic>.from(agentes!.map((x) => x.toJson())),
        "noConfirmados": noConfirmados == null ? null : List<dynamic>.from(noConfirmados!.map((x) => x.toJson())),
        "cancelados": cancelados == null ? null : List<dynamic>.from(cancelados!.map((x) => x.toJson())),
        "viajeActual": viajeActual == null ? null : viajeActual!.toJson(),
    };
}

class Agente {
    Agente({
        this.tripId,
        this.commentDriver,
        this.agentId,
        this.agentEmployeeId,
        this.agentUser,
        this.agentFullname,
        this.agentPhone,
        this.agentEmail,
        this.agentReferencePoint,
        this.neighborhoodName,
        this.districtName,
        this.townName,
        this.comment,
        this.departmentName,
        this.companyName,
        this.traveled,
        this.notTraveled,
        this.hourIn,
        this.hourForTrip,
        this.neighborhoodReferencePoint
    });

    int? tripId;
    dynamic commentDriver;
    int? agentId;
    String? agentEmployeeId;
    String? agentUser;
    String? comment;
    String? agentFullname;
    String? agentPhone;
    String? agentEmail;
    String? agentReferencePoint;
    String? neighborhoodName;
    String? districtName;
    String? townName;
    String? departmentName;
    String? companyName;
    dynamic traveled;
    dynamic notTraveled;
    String? hourIn;
    dynamic hourForTrip;
    String? neighborhoodReferencePoint;  

    factory Agente.fromJson(Map<String, dynamic> json) => Agente(
        tripId: json["tripId"],
        commentDriver: json["commentDriver"],
        agentId: json["agentId"],
        comment: json["comment"],
        agentEmployeeId: json["agentEmployeeId"],
        agentUser: json["agentUser"],
        agentFullname: json["agentFullname"],
        agentPhone: json["agentPhone"],
        agentEmail: json["agentEmail"],
        agentReferencePoint: json["agentReferencePoint"],
        neighborhoodName: json["neighborhoodName"],
        districtName: json["districtName"],
        townName: json["townName"],
        departmentName: json["departmentName"],
        companyName: json["companyName"],
        traveled: json["traveled"],
        notTraveled: json["notTraveled"],
        hourIn: json["hourIn"],
        hourForTrip: json["hourForTrip"],
        neighborhoodReferencePoint: json["neighborhoodReferencePoint"]
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "commentDriver": commentDriver,
        "agentId": agentId,
        "agentEmployeeId": agentEmployeeId,
        "agentUser": agentUser,
        "agentFullname": agentFullname,
        "agentPhone": agentPhone,
        "comment": comment,
        "agentEmail": agentEmail,
        "agentReferencePoint": agentReferencePoint,
        "neighborhoodName": neighborhoodName,
        "districtName": districtName,
        "townName": townName,
        "departmentName": departmentName,
        "companyName": companyName,
        "traveled": traveled,
        "notTraveled": notTraveled,
        "hourIn": hourIn,
        "hourForTrip": hourForTrip,
        "neighborhoodReferencePoint" : neighborhoodReferencePoint
    };
}

class ViajeActual {
    ViajeActual({
        this.tripId,
        this.tripDate,
        this.tripHour,
        this.tripStatus,
        this.driverFullname,
        this.tripVehicle,
        this.tripTypeVehicle,
        this.tripType,
        this.tripDescription,
        this.companyId,
        this.companyName,
        this.townName,
        this.traveled,
        this.notTraveled,
        this.totalAgents,
        this.neighborhoodReferencePoint
    });

    int? tripId;
    String? tripDate;
    String? tripHour;
    String? tripStatus;
    String? driverFullname;
    String? tripVehicle;
    dynamic tripTypeVehicle;
    String? tripType;
    dynamic tripDescription;
    int? companyId;
    String? companyName;
    dynamic townName;
    int? traveled;
    int? notTraveled;
    int? totalAgents;
    String? neighborhoodReferencePoint;  

    factory ViajeActual.fromJson(Map<String, dynamic> json) => ViajeActual(
        tripId: json["tripId"],
        tripDate: json["tripDate"],
        tripHour: json["tripHour"],
        tripStatus: json["tripStatus"],
        driverFullname: json["driverFullname"],
        tripVehicle: json["tripVehicle"],
        tripTypeVehicle: json["tripTypeVehicle"],
        tripType: json["tripType"],
        tripDescription: json["tripDescription"],
        companyId: json["companyId"],
        companyName: json["companyName"],
        townName: json["townName"],
        traveled: json["traveled"],
        notTraveled: json["notTraveled"],
        totalAgents: json["totalAgents"],
        neighborhoodReferencePoint: json["neighborhoodReferencePoint"]
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "tripDate": tripDate,
        "tripHour": tripHour,
        "tripStatus": tripStatus,
        "driverFullname": driverFullname,
        "tripVehicle": tripVehicle,
        "tripTypeVehicle": tripTypeVehicle,
        "tripType": tripType,
        "tripDescription": tripDescription,
        "companyId": companyId,
        "companyName": companyName,
        "townName": townName,
        "traveled": traveled,
        "notTraveled": notTraveled,
        "totalAgents": totalAgents,
        "neighborhoodReferencePoint" : neighborhoodReferencePoint
    };
}

class TripsList2 {
  final List<AgentInTripsPending>? trips;

  TripsList2({
    this.trips,
  });

  factory TripsList2.fromJson(List<dynamic> parsedJson) {

    List<AgentInTripsPending> trips = [];

    trips = parsedJson.map((i)=>AgentInTripsPending.fromJson(i)).toList();
    return new TripsList2(
       trips: trips,
    );
  }
}