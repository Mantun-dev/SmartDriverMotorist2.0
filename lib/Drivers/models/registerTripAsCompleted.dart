import 'dart:convert';

Driver driverFromJson(String str) => Driver.fromJson(json.decode(str));

String driverToJson(Driver data) => json.encode(data.toJson());

class Driver {
  Driver({
    this.ok,
    this.type,
    this.title,
    this.message,
  });

  bool? ok;
  String? type;
  String? title;
  String? message;

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        ok: json["ok"],
        type: json["type"],
        title: json["title"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "type": type,
        "title": title,
        "message": message,
      };
}
