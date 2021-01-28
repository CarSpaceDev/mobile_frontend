import 'dart:convert';

import 'package:carspace/model/User.dart';
import 'package:carspace/services/ApiService.dart';

class UserRepo {
  Future<CSUser> getEmail(String email) async {
    ApiService apiService = ApiService.create();
    var testResult = await apiService.getUserEmails({'email': email});
    var result = testResult.body[0]['email'];
    var returnResult = jsonDecode(result);
    return returnResult;
  }
}
