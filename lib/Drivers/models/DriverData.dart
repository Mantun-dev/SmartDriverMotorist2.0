// To parse this JSON data, do
//
//     final driverData = driverDataFromJson(jsonString);

import 'dart:convert';

DriverData driverDataFromJson(String str) => DriverData.fromJson(json.decode(str));

String driverDataToJson(DriverData data) => json.encode(data.toJson());

class DriverData {
    DriverData({
        this.driverId,
        this.driverDni,
        this.driverPhone,
        this.driverFullname,
        this.driverType,
        this.driverStatus,
        this.departmentId,
        this.driverUser,
        this.driverPassword,
        this.driverCoord
    });

    int driverId;
    String driverDni;
    String driverPhone;
    String driverFullname;
    String driverType;
    dynamic driverStatus;
    int departmentId;
    String driverUser;
    String driverPassword;
    dynamic driverCoord;

    factory DriverData.fromJson(Map<String, dynamic> json) => DriverData(
        driverId: json["driverId"],
        driverDni: json["driverDNI"],
        driverPhone: json["driverPhone"],
        driverFullname: json["driverFullname"],
        driverType: json["driverType"],
        driverStatus: json["driverStatus"],
        departmentId: json["departmentId"],
        driverUser: json["driverUser"],
        driverPassword: json["driverPassword"],
        driverCoord: json["driverCoord"],
    );

    Map<String, dynamic> toJson() => {
        "driverId": driverId,
        "driverDNI": driverDni,
        "driverPhone": driverPhone,
        "driverFullname": driverFullname,
        "driverType": driverType,
        "driverStatus": driverStatus,
        "departmentId": departmentId,
        "driverUser": driverUser,
        "driverPassword": driverPassword,
        "driverCoord": driverCoord
    };
}
