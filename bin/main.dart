import 'dart:io' show HttpServer, HttpRequest, WebSocket, WebSocketTransformer,SecurityContext;

import 'services/messagging_service.dart';

void main(){
  start();
}

void start() async{
  HttpServer server;
  try {
    var isTest = false;
    print('service started..');
    if(!isTest){
      //get certificates
      var context = SecurityContext.defaultContext;
      context.useCertificateChain('falan.crt');
      context.usePrivateKey('falan.key');
      //start secured server connection
      server = await HttpServer.bindSecure('0.0.0.0',
                      9002,
                      context);
    }else{
      server = await HttpServer.bind('localhost', 9002);
    }
    //call service
    var g = Msg();
    server.listen((request) {
      //try upgrade request to websocket
      WebSocketTransformer.upgrade(request).then((WebSocket client) {
          print('connection came'); 
          g.handleConnection(client);
      },onError: (err) => print('[!]Error -- ${err.toString()}'));
    });
  } catch (e) {
    print(e);
    //start again in 3 seconds
    Future.delayed(Duration(seconds: 3),(){
      start();
    });
  }
 
}


