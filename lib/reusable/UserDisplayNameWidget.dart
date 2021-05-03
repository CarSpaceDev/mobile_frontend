import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CSText.dart';

class UserDisplayNameWidget extends StatelessWidget {
  final String uid;
  UserDisplayNameWidget({@required this.uid});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> result) {
          if (result.hasData) {
            if(result.data.exists)
            return CSText(
              "${result.data.data()["displayName"]}".toUpperCase(),
              textType: TextType.Button,
              textColor: TextColor.Primary,
            );
            else return CSText(". . .");
          }
          return CSText(". . .");
        },);
  }
}
