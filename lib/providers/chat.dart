import 'package:flutter/foundation.dart';
import 'package:flutter_auth/Drivers/models/message_chat.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageDriver> mensaje2 = [];
  List<MessageDriver> get mensaje => mensaje2;

  addNewMessage(MessageDriver mensaje) {
    //print(mensaje.user);
    mensaje2.add(mensaje);
    notifyListeners();
  }
}
