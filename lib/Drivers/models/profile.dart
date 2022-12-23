// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
    Profile({
        this.driver,
        this.rating,
        this.percentageBars1,
        this.percentageBars2,
        this.percentageBars3,
    });

    Driver? driver;
    Map<String, double>? rating;
    PercentageBars? percentageBars1;
    PercentageBars? percentageBars2;
    PercentageBars? percentageBars3;

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        driver: Driver.fromJson(json["driver"]),
        rating: Map.from(json["rating"]).map((k, v) => MapEntry<String, double>(k, v.toDouble())),
        percentageBars1: PercentageBars.fromJson(json["percentageBars1"]),
        percentageBars2: PercentageBars.fromJson(json["percentageBars2"]),
        percentageBars3: PercentageBars.fromJson(json["percentageBars3"]),
    );

    Map<String, dynamic> toJson() => {
        "driver": driver!.toJson(),
        "rating": Map.from(rating!).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "percentageBars1": percentageBars1?.toJson(),
        "percentageBars2": percentageBars2?.toJson(),
        "percentageBars3": percentageBars3?.toJson(),
    };
}

class Driver {
    Driver({
        this.driverId,
        this.driverDni,
        this.driverPhone,
        this.driverFullname,
        this.driverType,
        this.driverStatus,
        this.departmentId,
        this.departmentName,
        this.driverCoord,
        this.monday,
        this.tuesday,
        this.wednesday,
        this.thursday,
        this.friday,
        this.saturday,
        this.sunday,
    });

    int? driverId;
    String? driverDni;
    String? driverPhone;
    String? driverFullname;
    String? driverType;
    bool? driverStatus;
    int? departmentId;
    String? departmentName;
    dynamic driverCoord;
    dynamic monday;
    dynamic tuesday;
    dynamic wednesday;
    dynamic thursday;
    dynamic friday;
    dynamic saturday;
    dynamic sunday;

    factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        driverId: json["driverId"],
        driverDni: json["driverDNI"],
        driverPhone: json["driverPhone"],
        driverFullname: json["driverFullname"],
        driverType: json["driverType"],
        driverStatus: json["driverStatus"],
        departmentId: json["departmentId"],
        departmentName: json["departmentName"],
        driverCoord: json["driverCoord"],
        monday: json["monday"],
        tuesday: json["tuesday"],
        wednesday: json["wednesday"],
        thursday: json["thursday"],
        friday: json["friday"],
        saturday: json["saturday"],
        sunday: json["sunday"],
    );

    Map<String, dynamic> toJson() => {
        "driverId": driverId,
        "driverDNI": driverDni,
        "driverPhone": driverPhone,
        "driverFullname": driverFullname,
        "driverType": driverType,
        "driverStatus": driverStatus,
        "departmentId": departmentId,
        "departmentName": departmentName,
        "driverCoord": driverCoord,
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thursday": thursday,
        "friday": friday,
        "saturday": saturday,
        "sunday": sunday,
    };
}

class PercentageBars {
    PercentageBars({
        this.stars5,
        this.stars4,
        this.stars3,
        this.stars2,
        this.stars1,
    });

    dynamic stars5;
    dynamic stars4;
    dynamic stars3;
    dynamic stars2;
    dynamic stars1;

    factory PercentageBars.fromJson(Map<String, dynamic> json) => PercentageBars(
        stars5: json["stars5"],
        stars4: json["stars4"],
        stars3: json["stars3"],
        stars2: json["stars2"],
        stars1: json["stars1"],
    );

    Map<String, dynamic> toJson() => {
        "stars5": stars5,
        "stars4": stars4,
        "stars3": stars3,
        "stars2": stars2,
        "stars1": stars1,
    };
}

