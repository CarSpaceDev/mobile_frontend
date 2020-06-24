import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage{

  writeString(String key, String value) async{
    final _storageService = await SharedPreferences.getInstance();
    _storageService.setString(key, value);
  }

  writeBool(String key, bool value) async{
    final _storageService = await SharedPreferences.getInstance();
    _storageService.setBool(key, value);
  }

  writeInt(String key, int value) async{
    final _storageService = await SharedPreferences.getInstance();
    _storageService.setInt(key, value);
  }

  writeFloat(String key, double value) async{
    final _storageService = await SharedPreferences.getInstance();
    _storageService.setDouble(key, value);
  }

  read(String key) async{
   final _storageService = await SharedPreferences.getInstance();
   return _storageService.get(key);
 }

 dynamic listKeys()async{
   final _storageService = await SharedPreferences.getInstance();
   return _storageService.getKeys();
 }

  delete(String key) async {
    final _storageService = await SharedPreferences.getInstance();
    return _storageService.getKeys();
  }

  destroy() async {
    final _storageService = await SharedPreferences.getInstance();
    return _storageService.clear();
  }

}