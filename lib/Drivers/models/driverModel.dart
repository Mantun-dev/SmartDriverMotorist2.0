// To parse this JSON data, do
//
//     final driver = driverFromJson(jsonString);

import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
  Driver({
    this.ok,
    this.driver,
  });

  bool ok;
  DriverClass driver;

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        ok: json["ok"],
        driver: DriverClass.fromJson(json["driver"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "driver": driver.toJson(),
      };
}

class DriverClass {
  DriverClass({
    this.driverId,
    this.driverDni,
    this.driverPhone,
    this.driverFullname,
    this.driverType,
    this.driverStatus,
    this.departmentId,
    this.driverUser,
    this.driverPassword,
  });

  int driverId;
  String driverDni;
  String driverPhone;
  String driverFullname;
  String driverType;
  bool driverStatus;
  int departmentId;
  String driverUser;
  String driverPassword;

  factory DriverClass.fromJson(Map<String, dynamic> json) => DriverClass(
        driverId: json["driverId"],
        driverDni: json["driverDNI"],
        driverPhone: json["driverPhone"],
        driverFullname: json["driverFullname"],
        driverType: json["driverType"],
        driverStatus: json["driverStatus"],
        departmentId: json["departmentId"],
        driverUser: json["driverUser"],
        driverPassword: json["driverPassword"],
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
      };
}
