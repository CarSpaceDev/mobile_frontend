
import 'package:carspace/constants/GlobalConstants.dart';

devLog(String identifier, dynamic message){
  if (StringConstants.debugMessages) {
    print(">>>>>>$identifier>>>>>>\n$message");
  }
}