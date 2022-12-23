// To parse this JSON data, do
//
//     final search = searchFromJson(jsonString);

import 'dart:convert';

Search searchFromJson(String str) => Search.fromJson(json.decode(str));

String searchToJson(Search data) => json.encode(data.toJson());

class Search {
    Search({
        this.ok,
        this.agent,
    });

    bool? ok;
    Agent? agent;

    factory Search.fromJson(Map<String, dynamic> json) => Search(
        ok: json["ok"],
        agent: Agent.fromJson(json["agent"]),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "agent": agent!.toJson(),
    };
}

class Agent {
    Agent({
        this.agentId,
        this.agentEmployeeId,
        this.agentUser,
        this.agentFullname,
        this.agentPhone,
        this.agentEmail,
        this.agentReferencePoint,
        this.neighborhoodName,
        this.neighborhoodSector,
        this.districtName,
        this.townName,
        this.departmentName,
        this.hourOut,
        this.msg,
        this.companyId
    });

    int? agentId;
    String? agentEmployeeId;
    String? agentUser;
    String? agentFullname;
    String? agentPhone;
    String? agentEmail;
    String? agentReferencePoint;
    String? neighborhoodName;
    int? neighborhoodSector;
    String? districtName;
    String? townName;
    String? departmentName;
    String? hourOut;
    String? msg;
    int? companyId;

    factory Agent.fromJson(Map<String, dynamic> json) => Agent(
        agentId: json["agentId"],
        agentEmployeeId: json["agentEmployeeId"],
        agentUser: json["agentUser"],
        agentFullname: json["agentFullname"],
        agentPhone: json["agentPhone"],
        agentEmail: json["agentEmail"],
        agentReferencePoint: json["agentReferencePoint"],
        neighborhoodName: json["neighborhoodName"],
        neighborhoodSector: json["neighborhoodSector"],
        districtName: json["districtName"],
        townName: json["townName"],
        departmentName: json["departmentName"],
        hourOut: json["hourOut"],
        msg: json["msg"],
        companyId:  json["companyId"]
    );

    Map<String, dynamic> toJson() => {
        "agentId": agentId,
        "agentEmployeeId": agentEmployeeId,
        "agentUser": agentUser,
        "agentFullname": agentFullname,
        "agentPhone": agentPhone,
        "agentEmail": agentEmail,
        "agentReferencePoint": agentReferencePoint,
        "neighborhoodName": neighborhoodName,
        "neighborhoodSector": neighborhoodSector,
        "districtName": districtName,
        "townName": townName,
        "departmentName": departmentName,
        "hourOut": hourOut,
        "msg": msg,
        "companyId": companyId
    };
}
