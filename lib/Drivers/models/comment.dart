// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

Comment commentFromJson(String str) => Comment.fromJson(json.decode(str));

String commentToJson(Comment data) => json.encode(data.toJson());

class Comment {
    Comment({
        this.ok,
        this.message,
        this.comment,
    });

    bool ok;
    String message;
    CommentClass comment;

    factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        ok: json["ok"],
        message: json["message"],
        comment: CommentClass.fromJson(json["comment"]),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "message": message,
        "comment": comment.toJson(),
    };
}

class CommentClass {
    CommentClass({
        this.commentDriver,
    });

    dynamic commentDriver;

    factory CommentClass.fromJson(Map<String, dynamic> json) => CommentClass(
        commentDriver: json["commentDriver"],
    );

    Map<String, dynamic> toJson() => {
        "commentDriver": commentDriver,
    };
}
