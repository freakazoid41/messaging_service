import 'package:dart_sqlite3/dart_sqlite3.dart';

import '../config.dart';
class Queue extends Config{
  Database db;
  int owner;
  int target;
  String msg;
  Queue({this.owner,this.target,this.msg}){
    //set database
    db = Database(db_path);
  }

  Future<bool> save() async{
    bool rsp;
    try{
      db.execute("insert into messages (owner, target,msg) values ('$owner','$target','$msg');");
      rsp = true;
    }catch(e){
      print(e);
      rsp = false;
    }
    db.close();
    return rsp;
  }


  Future<bool> cleanMessages() async{
    bool rsp;
    try{
      db.execute("delete from  messages where target='$target' ");
      rsp = true;
    }catch(e){
      print(e);
      rsp = false;
    }
    db.close();
    return rsp;
  }

  Stream<Map<String,dynamic>> getMessages() async*{
    print("select * from messages where target = '$target';");
    var result = db.query("select * from messages where target = '$target';");
    for (var r in result) {
      yield {
        'owner':r.readColumn('owner'),
        'target':r.readColumn('target'),
        'msg':r.readColumn('msg')
      };
    }
  }
}