import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

class FirebaseAnalyticsService implements IAnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _enabled = true;

  @override
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_enabled) return;

    try {
      // Limpiar parámetros y convertir a Object?
      final cleanParams = _cleanParameters(parameters);
      _analytics.logEvent(name: name, parameters: cleanParams);

      // Debug en desarrollo
      if (kDebugMode) {
        print('📊 Firebase Event: $name');
        print('   Params: $cleanParams');
      }
    } catch (e) {
      print('❌ Error logging event: $e');
    }
  }

  @override
  void logScreenView(String screenName, {Map<String, dynamic>? parameters}) {
    if (!_enabled) return;

    try {
      final cleanParams = _cleanParameters(parameters);
      _analytics.logScreenView(
        screenName: screenName,
        parameters: cleanParams,
      );

      if (kDebugMode) {
        print('📱 Screen View: $screenName');
      }
    } catch (e) {
      print('❌ Error logging screen view: $e');
    }
  }

  @override
  void setUserId(String? userId) {
    if (!_enabled) return;
    _analytics.setUserId(id: userId);
  }

  @override
  void setUserProperties(Map<String, dynamic> properties) {
    if (!_enabled) return;

    properties.forEach((key, value) {
      _analytics.setUserProperty(name: key, value: value?.toString());
    });
  }

  @override
  void setAnalyticsEnabled(bool enabled) {
    _enabled = enabled;
    _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  Map<String, Object>? _cleanParameters(Map<String, dynamic>? params) {
    if (params == null) return null;

    final clean = <String, Object>{};
    params.forEach((key, value) {
      if (value != null) {
        // Convertir tipos no soportados a String
        if (value is DateTime) {
          clean[key] = value.toIso8601String();
        } else if (value is List) {
          clean[key] = value.join(',');
        } else if (value is Map) {
          clean[key] = value.toString();
        } else {
          clean[key] = value; 
        }
      }
    });
    return clean;
  }
}
