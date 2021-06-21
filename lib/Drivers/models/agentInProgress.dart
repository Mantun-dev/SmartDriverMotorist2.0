// To parse this JSON data, do
//
//     final agentInTripsInProgress = agentInTripsInProgressFromJson(jsonString);

import 'dart:convert';

List<AgentInTripsInProgress> agentInTripsInProgressFromJson(String str) => List<AgentInTripsInProgress>.from(json.decode(str).map((x) => AgentInTripsInProgress.fromJson(x)));

String agentInTripsInProgressToJson(List<AgentInTripsInProgress> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AgentInTripsInProgress {
    AgentInTripsInProgress({
        this.tripAgent,
        this.actualTravel,
    });

    List<TripAgent> tripAgent;
    ActualTravel actualTravel;

    factory AgentInTripsInProgress.fromJson(Map<String, dynamic> json) => AgentInTripsInProgress(
        tripAgent: json["tripAgent"] == null ? null : List<TripAgent>.from(json["tripAgent"].map((x) => TripAgent.fromJson(x))),
        actualTravel: json["actualTravel"] == null ? null : ActualTravel.fromJson(json["actualTravel"]),
    );

    Map<String, dynamic> toJson() => {
        "tripAgent": tripAgent == null ? null : List<dynamic>.from(tripAgent.map((x) => x.toJson())),
        "actualTravel": actualTravel == null ? null : actualTravel.toJson(),
    };
}

class ActualTravel {
    ActualTravel({
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
    });

    int tripId;
    String tripDate;
    String tripHour;
    String tripStatus;
    String driverFullname;
    String tripVehicle;
    dynamic tripTypeVehicle;
    String tripType;
    dynamic tripDescription;
    int companyId;
    String companyName;
    dynamic townName;
    dynamic traveled;
    int notTraveled;
    int totalAgents;

    factory ActualTravel.fromJson(Map<String, dynamic> json) => ActualTravel(
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
    };
}

class TripAgent {
    TripAgent({
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
    });

    int tripId;
    dynamic commentDriver;
    int agentId;
    String agentEmployeeId;
    String agentUser;
    String agentFullname;
    String agentPhone;
    String agentEmail;
    String agentReferencePoint;
    String neighborhoodName;
    String districtName;
    String townName;
    String departmentName;
    String companyName;
    dynamic traveled;
    int notTraveled;
    String timeName;
    String hourIn;
    String hourForTrip;
    dynamic didntGetOut;

    factory TripAgent.fromJson(Map<String, dynamic> json) => TripAgent(
        tripId: json["tripId"],
        commentDriver: json["commentDriver"],
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
        notTraveled: json["notTraveled"] == null ? null : json["notTraveled"],
        timeName: json["timeName"],
        hourIn: json["hourIn"],
        hourForTrip: json["hourForTrip"],
        didntGetOut: json["didntGetOut"],
    );

    Map<String, dynamic> toJson() => {
        "tripId": tripId,
        "commentDriver": commentDriver,
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
        "notTraveled": notTraveled == null ? null : notTraveled,
        "timeName": timeName,
        "hourIn": hourIn,
        "hourForTrip": hourForTrip,
        "didntGetOut": didntGetOut,
    };
}

class TripsList4 {
  final List<AgentInTripsInProgress> trips;

  TripsList4({
    this.trips,
  });

  factory TripsList4.fromJson(List<dynamic> parsedJson) {

    List<AgentInTripsInProgress> trips = [];

    trips = parsedJson.map((i)=>AgentInTripsInProgress.fromJson(i)).toList();
    return new TripsList4(
       trips: trips,
    );
  }
}