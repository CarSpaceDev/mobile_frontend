import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum NotificationType { Info, Action }

class CSNotification extends Equatable {
  final String uid;
  final bool opened;
  final String title;
  final DateTime dateCreated;
  final NotificationType type;
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [uid, opened, title, dateCreated, type, data];

  CSNotification({this.uid, this.opened, this.title, this.dateCreated, this.type, this.data});

  CSNotification.fromDoc(QueryDocumentSnapshot json)
      : uid = json.id,
        opened = json.data()["opened"] as bool,
        title = json.data()["title"] as String,
        dateCreated = json.data()["dateCreated"].toDate(),
        type = NotificationType.values[json.data()["type"]],
        data = json.data()["data"];

  toJson() {
    return {
      "uid": this.uid,
      "type": this.type,
      "title": this.title,
      "data": this.data,
      "opened": this.opened,
      "dateCreated": this.dateCreated
    };
  }
}
