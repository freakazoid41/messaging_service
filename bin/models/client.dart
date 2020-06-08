import 'dart:io' show WebSocket;
import 'dart:convert';

class Client{
  int id;
  Map<String,WebSocket> connections  = {};

  Client(this.id);

  /**
   * this method will register client connection
   */
  String register(WebSocket conn){
    //register new connection to object
    String key = (new DateTime.now().millisecondsSinceEpoch).toString();
    connections[key] = conn;
    //return key
    return key;
  }

  /**
   * this function will remove connection from client
   */
  void clean(key){
    //clean closed connection
    connections.remove(key);
  }

  /**
   * this method will send data to client connections
   */
  Future<bool> send(Map<String,dynamic> data) async{
    //convert to string
    String response = jsonEncode(data);
    try {
      //send data to every connections of client
      for(String key in connections.keys){
        connections[key].add(response);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}