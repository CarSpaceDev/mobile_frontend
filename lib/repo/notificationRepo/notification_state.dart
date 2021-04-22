part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  @override
  List<Object> get props => [];
}

class NotificationsReady extends NotificationState {
  final List<CSNotification> notifications;
  NotificationsReady({this.notifications});
  @override
  List<Object> get props => [notifications];
}