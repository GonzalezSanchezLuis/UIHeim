import 'package:flutter/foundation.dart';

class MoveNotificationDriverViewmodel extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _latestMoveData;

  List<Map<String, dynamic>> get notifications => _notifications;
  Map<String, dynamic>? get latestMoveData => _latestMoveData;

  void addNotification(Map<String, dynamic> notification) {
    _notifications.add(notification);

    _latestMoveData = notification['move'] as Map<String, dynamic>?;

    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void clearLatestMoveData() {
    _latestMoveData = null;
  }
}
