import 'dart:async';

import 'dart:convert';
import 'package:flutter_auth/helpers/exception_handlers.dart';
import 'package:http/http.dart' as http;

class BaseClient {
  static const int timeOutDuration = 35;
  bool internet = true;
  //GET
  Future<dynamic> get(String url, dynamic header) async {
    var uri = Uri.parse(url);
    try {
      var response = await http
          .get(uri, headers: header)
          .timeout(const Duration(seconds: timeOutDuration));
      internet = true;

      return _processResponse(response);
    } catch (e) {
      internet = false;

      // ignore: avoid_print
      print(ExceptionHandlers().getExceptionString(e));
    }
  }

  //POST
  Future<dynamic> post(String url, dynamic payloadObj, dynamic header) async {
    var uri = Uri.parse(url);
    var payload = jsonEncode(payloadObj);
    try {
      var response = await http
          .post(uri, body: payload, headers: header)
          .timeout(const Duration(seconds: timeOutDuration));
      internet = true;
      print(response.body);
      print(payload);
      return _processResponse(response);
    } catch (e) {
      // ignore: avoid_print
      print(ExceptionHandlers().getExceptionString(e));
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = response.body;
        return responseJson;
      case 400: //Bad request
        throw BadRequestException(jsonDecode(response.body)['details']);
      case 401: //Unauthorized
        throw UnAuthorizedException(jsonDecode(response.body)['details']);
      case 403: //Forbidden
        throw UnAuthorizedException(jsonDecode(response.body)['details']);
      case 404: //Resource Not Found
        throw NotFoundException(jsonDecode(response.body)['details']);
      case 500:
      default:
        throw FetchDataException('Algo salio mal ${response.statusCode}');
    }
  }
}
