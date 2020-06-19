
import 'dart:io';
import 'dart:convert';
import '../models/client.dart';
import '../models/queue.dart';


class Msg {
  //this container will contains clients
  Map<String,Client> clients = {};

  /**
   * this method will handle connections
   */
  void handleConnection(WebSocket conn) {
    //connection key
    String key;
    String id;
    try{
      //start tilstening connection channel
      conn.listen((data) {
        //decode message
        Map<String,dynamic> msg = jsonDecode(data);
        id = msg['id'];
        //check event
        if(msg['event'] == 'register'){
          key = handleRegister(conn,msg);
        }else{
          handleEvents(conn,msg,id);
        }
        
      }, onDone: () {
        //clean broken connection
        if(clients[id] != null){
          clients[id].clean(key);
          //check if any connection left
          if(clients[id].connections.isEmpty){
            clients.remove(id);
            //send transaction to everyone
            handleEvents(null,{'event':'2','type':'2'},id);
          } 
        }else{
          handleEvents(null,{'event':'2','type':'2'},id);
        }
      });
    }catch(e){
      print(e);
      if(key != null && id != null){
        if(clients.containsKey(id)){
          clients.remove(id);
        }
      }
    }
  }
  
  /**
   * this handler will register connected user
   */
  String handleRegister(WebSocket conn,Map<String,dynamic> msg){
    Client cl;
    String key;

    //register connection to client
    if(clients.containsKey(msg['id'])){
      print('appended');
      //print(json.encode(clients[msg['id']]));
      //append connection
      cl = clients[msg['id']];
      key = cl.register(conn);
    }else{
      print('added..');
      //create new connection
      cl = Client(int.parse(msg['id']));
      key = cl.register(conn);
      //register connection
      clients[msg['id']] = cl;
      //send messages to new entered client
      var queue = Queue(target: int.parse(msg['id']));
      queue.getMessages().listen((item) {
        cl.send({
          'event':'3',
          'data':{
            'owner':item['owner'],
            'msg':item['msg']
          }
        });
        print(item);
      },onDone:(){
        queue.cleanMessages();
      });
      //send transaction to everyone (because new registered)
      handleEvents(null,{'event':'2','type':'1'},msg['id']);
    }
    return key;
  }

  /**
   * this handle will handle events like client registered,client dropped etc..
   */
  void handleEvents(WebSocket conn,Map<String,dynamic> obj,String id){
    switch(obj['event']){
      case '1':
        //get all clients for new register
        var rsp =<String,dynamic>{
          'event':'2',
          'data':[]
        };
        //append client info
        for(var cid in clients.keys){
          if (id != cid) {
            rsp['data'].add({
              'id':cid
            });
          } 
        }
        //send all clients to requested client
        conn.add(jsonEncode(rsp));
      break;
      case '2':
        //client sync
        //send person transaction to everyone
        //type for transaction type (1 : entered , 2 :dropped)..
        for(var cid in clients.keys){
          clients[cid].send({
            'event':'1',
            'type':obj['type'],
            'data':{
              'id':id
            }
          });
        }
        break;
      case '3':
      //check if is to everyone or just for one person 
      if(obj['target'] != 'all'){
        if(clients[obj['target']] == null){
          //save to queue
          Queue(owner: int.parse(obj['id']),target: int.parse(obj['target']),msg: obj['msg']).save();
        }else{
          clients[obj['target']].send({
            'event':'3',
            'data':{
              'owner':int.parse(obj['id']),
              'msg':obj['msg']
            }
          });
        }
        
      }else{
        //send to everyone
      }
      print(obj);
      break;
      
    }
  }

  
}
