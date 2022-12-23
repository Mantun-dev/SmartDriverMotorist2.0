// To parse this JSON data, do
//
//     final findAgentSolid = findAgentSolidFromJson(jsonString);

import 'dart:convert';

FindAgentSolid findAgentSolidFromJson(String str) => FindAgentSolid.fromJson(json.decode(str));

String findAgentSolidToJson(FindAgentSolid data) => json.encode(data.toJson());

class FindAgentSolid {
    FindAgentSolid({
        this.type,
        this.title,
        this.message,
        this.agent,
    });

    String? type;
    String? title;
    String? message;
    Agent? agent;

    factory FindAgentSolid.fromJson(Map<String, dynamic> json) => FindAgentSolid(
        type: json["type"],
        title: json["title"],
        message: json["message"],
        agent: Agent.fromJson(json["agent"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "title": title,
        "message": message,
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
        this.hourAgent,
        this.companyId,
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
    String? hourAgent;
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
        hourAgent: json["hourAgent"],
        companyId: json["companyId"],
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
        "hourAgent": hourAgent,
        "companyId": companyId,
    };
}
