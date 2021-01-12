import 'package:carspace/constants/GlobalConstants.dart';
import 'package:carspace/model/Notification.dart';
import 'package:carspace/screens/Home/VehicleAddAuthDetails.dart';
import 'package:carspace/services/ApiService.dart';
import 'package:carspace/services/AuthService.dart';
import 'package:flutter/material.dart';

import '../../serviceLocator.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationFromApi data;
  //callback is normally used for message or remove notification and refresh the list screen
  final Function callback;
  NotificationWidget({@required this.data, this.callback});
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState(this.data, this.callback);
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final Function callback;
  NotificationFromApi data;
  _NotificationWidgetState(NotificationFromApi data, this.callback) {
    print(data.toJson());
    this.data = data;
  }
  @override
  Widget build(BuildContext context) {
    if (data.type == 0) {
      return _type0NotificationGenericMessage();
    } else if (data.type == 1) {
      return _type1Notification();
    }
    return _unsupportedType();
  }

  Widget _type0NotificationGenericMessage() {
    return InkWell(
      onTap: () {
        if (data.opened == false) {
          locator<ApiService>().setNotificationAsSeen(uid: locator<AuthService>().currentUser().uid, notificationUid: data.uid);
          if (callback != null) callback();
        }
      },
      child: Padding(
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
                Container(
                  width: MediaQuery.of(context).size.width * .6,
                  child: Column(
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
                      Text(data.data["message"], style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          data.dateCreated.toString().substring(0, data.dateCreated.toString().length - 5),
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _type1Notification() {
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
              Container(
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
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
                    Text(""),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        data.dateCreated.toString().substring(0, data.dateCreated.toString().length - 5),
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  if (data.opened == false) {
                    locator<ApiService>().setNotificationAsSeen(uid: locator<AuthService>().currentUser().uid, notificationUid: data.uid);
                    if (callback != null) callback();
                  }
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), child: VehicleAddAuthDetails(code: data.data["code"]));
                      });
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

  Widget _unsupportedType() {
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
              Container(
                width: MediaQuery.of(context).size.width * .6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Unsupported Notification Type",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text("Notification type " + data.type.toString() + "\nPlease check NotificationWidget logic",
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        data.dateCreated.toString().substring(0, data.dateCreated.toString().length - 5),
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  locator<ApiService>().setNotificationAsSeen(uid: locator<AuthService>().currentUser().uid, notificationUid: data.uid);
                  if (callback != null) callback();
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
                    "Okay",
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
