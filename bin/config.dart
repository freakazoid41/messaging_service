class Config{
  static bool isTest = false;
  String db_path;

  Config(){
    if(isTest){
      db_path = 'pickle.db';
    }else{
      db_path = '/var/www/services/socket_services/pickle.db';
    }
  }
}