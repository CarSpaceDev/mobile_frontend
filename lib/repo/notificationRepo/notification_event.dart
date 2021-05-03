part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}

class InitializeNotificationRepo extends NotificationEvent {
  final String uid;
  InitializeNotificationRepo({this.uid});
  @override
  List<Object> get props => [uid];
}

class NotificationsUpdated extends NotificationEvent {
  final List<CSNotification> notifications;
  NotificationsUpdated({this.notifications});
  @override
  List<Object> get props => [notifications];
}
class NotificationOpened extends NotificationEvent {
  final String uid;
  NotificationOpened({this.uid});
  @override
  List<Object> get props => [uid];
}

class NewNotificationReceived extends NotificationEvent {
  NewNotificationReceived();
  @override
  List<Object> get props => [];
}
class ClearAllNotifications extends NotificationEvent {
  ClearAllNotifications();
  @override
  List<Object> get props => [];
}
class MarkAllAsSeen extends NotificationEvent {
  MarkAllAsSeen();
  @override
  List<Object> get props => [];
}


class DisposeNotificationRepo extends NotificationEvent {
  @override
  List<Object> get props => [];
}
