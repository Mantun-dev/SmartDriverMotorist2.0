import 'dart:async';
import 'dart:io';

class ExceptionHandlers {
  getExceptionString(error) {
    if (error is SocketException) {
      return 'Sin conexión a internet.';
    }

    if (error is HttpException) {
      return 'Se produjo un error HTTP.';
    }

    if (error is FormatException) {
      return 'Formato de datos no válido.';
    }

    if (error is TimeoutException) {
      return 'La solicitud se ha agotado.';
    }

    if (error is BadRequestException) {
      return error.message.toString();
    }

    if (error is UnAuthorizedException) {
      return error.message.toString();
    }
    if (error is NotFoundException) {
      return error.message.toString();
    }
    if (error is FetchDataException) {
      return error.message.toString();
    }
    return 'Unknown error occured.';
  }
}

class AppException {
  final String? message;
  final String? prefix;
  final String? url;

  AppException([this.message, this.prefix, this.url]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, String? url])
      : super(message, 'Mala solicitud', url);
}

class FetchDataException extends AppException {
  FetchDataException([String? message, String? url])
      : super(message, 'No se puede procesar la solicitud', url);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException([String? message, String? url])
      : super(message, 'La API no responde', url);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, String? url])
      : super(message, 'Solicitud no autorizada', url);
}

class NotFoundException extends AppException {
  NotFoundException([String? message, String? url])
      : super(message, 'Página no encontrada', url);
}
