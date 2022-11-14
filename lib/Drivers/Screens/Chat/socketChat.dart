import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class StreamSocket {
  final socketResponse = StreamController<dynamic>();
  Stream<dynamic> get getResponse => socketResponse.stream;

  final String host;
  IO.Socket socket;

  StreamSocket({this.host}) {
    socket = IO.io(
        'http://$host',
        IO.OptionBuilder().setTransports(['websocket'])
            //.enableForceNewConnection() // for Flutter or Dart VM
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());

    print('hola');
  }

  void connectAndListen() {
    socket.on('connect', (_) {
      // ignore: avoid_print
      print('connected to chat');
      //socket.emit('msg', 'test');
    });

    // ignore: avoid_print
    socket.onConnectTimeout((data) => print('timeout'));
    // ignore: avoid_print
    socket.onConnectError((error) => print(error.toString()));
    // ignore: avoid_print
    socket.onError((error) => print(error.toString()));

    socket.on(
        'unauthorized',
        (msg) => {
              // ignore: avoid_print
              print('no doy'),
              // ignore: avoid_print
              print(msg), // 'jwtoken not provided' || 'access denied'
            });
    // socket.on('terminal:location', (data) {
    //   //print('si doy');
    //   //print(data);
    //   if (!_socketResponse.isClosed) _socketResponse.sink.add(data);
    // });
    // ignore: avoid_print
    socket.onDisconnect((_) => print('disconnect to chat'));
  }

  // void sendTextMessage(String message) {
  //   socket.emit('msg', message);
  // }

  // void sendCommands(Map message) {
  //   socket.emit('terminal:command', message);
  // }

  // void sendAlarmFind(Map message) {
  //   socket.emit('terminal:find', message);
  // }

  // void sendOperateDelay(Map relay) {
  //   socket.emit('terminal:relay', relay);
  // }

  void connect() {}

  void close() {
    socketResponse.close();
    //socket.destroy();
    socket.close();
    //socket.disconnect().close();
  }
}
