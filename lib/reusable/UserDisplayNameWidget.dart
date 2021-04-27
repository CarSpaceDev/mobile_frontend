import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'CSText.dart';

class UserDisplayNameWidget extends StatelessWidget {
  final String uid;
  UserDisplayNameWidget({@required this.uid});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: locator<ApiService>().getUserData(uid: uid),
        builder: (context, result) {
          if (result.hasData) {
            return CSText(
              "${result.data.body["displayName"]}".toUpperCase(),
              textType: TextType.Button,
              textColor: TextColor.Primary,
            );
          }
          return CSText(". . .");
        },);
  }
}
