// To parse this JSON data, do
//
//     final agentInTripsCompleted = agentInTripsCompletedFromJson(jsonString);

import 'dart:convert';

List<AgentInTripsCompleted> agentInTripsCompletedFromJson(String str) => List<AgentInTripsCompleted>.from(json.decode(str).map((x) => AgentInTripsCompleted.fromJson(x)));

String agentInTripsCompletedToJson(List<AgentInTripsCompleted> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AgentInTripsCompleted {
    AgentInTripsCompleted({
        this.inTrip,
        this.cancelAgent,
        this.tripActual,
    });

    List<CancelAgent>? inTrip;
    List<CancelAgent>? cancelAgent;
    TripActual? tripActual;

    factory AgentInTripsCompleted.fromJson(Map<String, dynamic> json) => AgentInTripsCompleted(
        inTrip: json["inTrip"] == null ? null : List<CancelAgent>.from(json["inTrip"].map((x) => CancelAgent.fromJson(x))),
        cancelAgent: json["CancelAgent"] == null ? null : List<CancelAgent>.from(json["CancelAgent"].map((x) => CancelAgent.fromJson(x))),
        tripActual: json["tripActual"] == null ? null : TripActual.fromJson(json["tripActual"]),
    );

    Map<String, dynamic> toJson() => {
        "inTrip": inTrip == null ? null : List<dynamic>.from(inTrip!.map((x) => x.toJson())),
        "CancelAgent": cancelAgent == null ? null : List<dynamic>.from(cancelAgent!.map((x) => x.toJson())),
        "tripActual": tripActual == null ? null : tripActual!.toJson(),
    };
}

class CancelAgent {
    CancelAgent({
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
        this.departmentName,
        this.companyName,
        this.traveled,
        this.notTraveled,
        this.timeName,
        this.hourIn,
        this.hourForTrip,
        this.didntGetOut,
        this.neighborhoodReferencePoint,
        this.latitude, // New latitude field
        this.longitude, // New longitude field
    });

    int? tripId;
    String? commentDriver;
    int? agentId;
    String? agentEmployeeId;
    String? agentUser;
    String? agentFullname;
    String? agentPhone;
    String? agentEmail;
    String? agentReferencePoint;
    String? neighborhoodName;
    String? districtName;
    String? townName;
    String? departmentName;
    String? companyName;
    int? traveled;
    dynamic notTraveled;
    String? timeName;
    String? hourIn;
    String? hourForTrip;
    dynamic didntGetOut;
    String? neighborhoodReferencePoint;
    double? latitude; // New latitude field
    double? longitude; // New longitude field

    factory CancelAgent.fromJson(Map<String, dynamic> json) => CancelAgent(
        tripId: json["tripId"],
        commentDriver: json["commentDriver"] == null ? null : json["commentDriver"],
        agentId: json["agentId"],
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
        timeName: json["timeName"],
        hourIn: json["hourIn"],
        hourForTrip: json["hourForTrip"],
        didntGetOut: json["didntGetOut"],
        neighborhoodReferencePoint: json["neighborhoodReferencePoint"],
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "commentDriver": commentDriver == null ? null : commentDriver,
        "agentId": agentId,
        "agentEmployeeId": agentEmployeeId,
        "agentUser": agentUser,
        "agentFullname": agentFullname,
        "agentPhone": agentPhone,
        "agentEmail": agentEmail,
        "agentReferencePoint": agentReferencePoint,
        "neighborhoodName": neighborhoodName,
        "districtName": districtName,
        "townName": townName,
        "departmentName": departmentName,
        "companyName": companyName,
        "traveled": traveled,
        "notTraveled": notTraveled,
        "timeName": timeName,
        "hourIn": hourIn,
        "hourForTrip": hourForTrip,
        "didntGetOut": didntGetOut,        
        "neighborhoodReferencePoint": neighborhoodReferencePoint,
        "latitude": latitude,
        "longitude": longitude,
    };
}

class TripActual {
    TripActual({
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
        this.neighborhoodReferencePoint,
        this.latitude, // New latitude field
        this.longitude, // New longitude field
    });

    int? tripId;
    String? tripDate;
    String? tripHour;
    String? tripStatus;
    String? driverFullname;
    String? tripVehicle;
    String? tripTypeVehicle;
    String? tripType;
    dynamic tripDescription;
    int? companyId;
    String? companyName;
    String? townName;
    int? traveled;
    int? notTraveled;
    int? totalAgents;
    String? neighborhoodReferencePoint;
    double? latitude; // New latitude field
    double? longitude; // New longitude field

    factory TripActual.fromJson(Map<String, dynamic> json) => TripActual(
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
        neighborhoodReferencePoint: json["neighborhoodReferencePoint"],
        latitude: json["latitude"],
        longitude: json["longitude"],
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
        "neighborhoodReferencePoint": neighborhoodReferencePoint,
        "latitude": latitude,
        "longitude": longitude,
    };
}

class TripsList3 {
  final List<AgentInTripsCompleted>? trips;

  TripsList3({
    this.trips,
  });

  factory TripsList3.fromJson(List<dynamic> parsedJson) {

    List<AgentInTripsCompleted> trips = [];

    trips = parsedJson.map((i)=>AgentInTripsCompleted.fromJson(i)).toList();
    return new TripsList3(
       trips: trips,
    );
  }
}