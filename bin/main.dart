import 'dart:io';

import 'services/messagging_service.dart';
class Helper {
  void printing(String someText){
    print(someText);
  }
}
void main() async {
  
  var g = Msg();
  var server = await HttpServer.bind('localhost', 8000);
  server.transform(WebSocketTransformer()).listen((WebSocket client) async{
    print('connection came'); 
    g.handleConnection(client);
  });
}


