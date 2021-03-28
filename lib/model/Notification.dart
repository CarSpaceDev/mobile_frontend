class NotificationFromApi {
  String uid;
  bool opened;
  String title;
  DateTime dateCreated;
  int type;
  Map<String, dynamic> data;

  NotificationFromApi({this.uid, this.opened, this.title, this.dateCreated, this.type, this.data});

  NotificationFromApi.fromJson(Map<String, dynamic> json)
      : uid = json["uid"] as String,
        opened = json["opened"] as bool,
        title = json["title"] as String,
        dateCreated = DateTime.parse(json["dateCreated"]),
        type = json["type"] as int,
        data = json["data"];

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
