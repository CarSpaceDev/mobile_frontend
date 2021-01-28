import 'package:carspace/model/Notification.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';
import 'NotificationWidget.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<Map<String, dynamic>> notifications = [];
  List<Widget> nWidgets = [];
  bool retrieval = false;

  @override
  void initState() {
    _refreshList();
    super.initState();
  }

  _refreshList() {
    setState(() {
      nWidgets = [];
      notifications = [];
      retrieval = false;
    });
    locator<ApiService>().getNotifications(uid: locator<AuthService>().currentUser().uid).then((v) {
      if (v.statusCode == 200) {
        notifications = List<Map<String, dynamic>>.from(v.body);
        notifications.forEach((v) {
          NotificationFromApi temp = NotificationFromApi.fromJson(v);
          nWidgets.add(NotificationWidget(data: temp, callback: _refreshList));
        });
        setState(() {
          retrieval = true;
        });
      } else {
        setState(() {
          retrieval = true;
        });
      }
    }).catchError((err) {
      setState(() {
        retrieval = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: nWidgets.length == 0
                ? retrieval
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [Text("No notifications at the moment")],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [Text("Getting notifications ... ")],
                      )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: nWidgets,
                    ),
                  ),
          ),
          Container(
            height: 50,
            child: FlatButton(
              padding: EdgeInsets.all(4),
              onPressed: Navigator.of(context).pop,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: Colors.grey,
                ),
                child: Center(
                    child: Icon(
                  Icons.clear,
                  color: Colors.white,
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
