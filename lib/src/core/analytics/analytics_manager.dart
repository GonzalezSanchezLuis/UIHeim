import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'analytics_service.dart';

class AnalyticsManager implements IAnalyticsService {
  final List<IAnalyticsService> _services;
  bool _enabled = true;

  AnalyticsManager(this._services);

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_enabled) return;

    // Agregar timestamp a todos los eventos
    final enrichedParams = {
      'timestamp': DateTime.now().toIso8601String(),
      'platform': _getPlatform(),
      ...?parameters,
    };

    for (var service in _services) {
      try {
        service.logEvent(name, parameters: enrichedParams);
      } catch (e) {
        print('❌ Analytics error on ${service.runtimeType}: $e');
      }
    }
  }

  @override
  void logScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    if (!_enabled) return;

    final enrichedParams = {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?parameters,
    };

    for (var service in _services) {
      try {
        service.logScreenView(screenName, parameters: enrichedParams);
      } catch (e) {
        print('❌ Analytics error on ${service.runtimeType}: $e');
      }
    }
  }

  @override
  void setUserId(String? userId) {
    for (var service in _services) {
      try {
        service.setUserId(userId);
      } catch (e) {
        print('❌ Analytics error on ${service.runtimeType}: $e');
      }
    }
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    if (!_enabled) return;

    for (var service in _services) {
      try {
        service.setUserProperties(properties);
      } catch (e) {
        print('❌ Analytics error on ${service.runtimeType}: $e');
      }
    }
  }

  @override
  void setAnalyticsEnabled(bool enabled) {
    _enabled = enabled;
    for (var service in _services) {
      try {
        service.setAnalyticsEnabled(enabled);
      } catch (e) {
        print('❌ Analytics error on ${service.runtimeType}: $e');
      }
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web'; // ignore: dead_code
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
