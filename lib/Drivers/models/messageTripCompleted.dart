import 'dart:convert';

Driver2 driverFromJson(String str) => Driver2.fromJson(json.decode(str));

String driverToJson(Driver2 data) => json.encode(data.toJson());

class Driver2 {
  Driver2({
    this.ok,
    this.type,
    this.title,
    this.message,
  });

  bool ok;
  String type;
  String title;
  String message;

  factory Driver2.fromJson(Map<String, dynamic> json) => Driver2(
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
