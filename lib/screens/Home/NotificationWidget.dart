import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Notification.dart';
import 'package:carspace/screens/Home/VehicleAddAuthDetails.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationFromApi data;
  NotificationWidget({@required this.data});
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState(this.data);
}

class _NotificationWidgetState extends State<NotificationWidget> {
  NotificationFromApi data;
  _NotificationWidgetState(NotificationFromApi data) {
    print(data.toJson());
    this.data = data;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(color: data.opened ? Colors.grey[600] : themeData.secondaryHeaderColor, borderRadius: BorderRadius.circular(5.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      data.title,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  data.type == 0
                      ? Text(
                          data.data["message"],
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        )
                      : Text(""),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      data.dateCreated.toString().substring(0, data.dateCreated.toString().length - 5),
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  )
                ],
              ),
              InkWell(
                onTap: () async {
                  if (data.type == 1) {
                    print(data.data["code"]);
                    Navigator.of(context).pop();
                    locator<ApiService>().setNotificationAsSeen(uid: locator<AuthService>().currentUser().uid, notificationUid: data.uid);
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) {
                          return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), child: VehicleAddAuthDetails(code: data.data["code"]));
                        });
                  }
                },
                child: Container(
                  height: 9.0 * 3,
                  width: 16.0 * 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: Colors.grey,
                  ),
                  child: Center(
                      child: Text(
                    "See More",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}