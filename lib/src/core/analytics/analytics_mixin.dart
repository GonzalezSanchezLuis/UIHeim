import 'package:get_it/get_it.dart';
import 'analytics_service.dart';
import 'analytics_events.dart';

/// Mixin para facilitar el tracking desde cualquier widget
mixin AnalyticsMixin {
  IAnalyticsService get _analytics => GetIt.instance<IAnalyticsService>();

  /// Trackear un evento simple
  void trackEvent(String name, {Map<String, dynamic>? params}) {
    _analytics.logEvent(name, parameters: params);
  }

  /// Trackear vista de pantalla
  void trackScreenView(String screenName, {Map<String, dynamic>? params}) {
    _analytics.logScreenView(screenName, parameters: params);
  }

  /// Trackear click de botón (conveniencia)
  void trackButtonClick(String buttonName, {Map<String, dynamic>? extra}) {
    _analytics.logEvent(
      AnalyticsEvents.buttonClick,
      parameters: {
        'button_name': buttonName,
        ...?extra,
      },
    );
  }

  /// Trackear error
  void trackError(String errorType, String errorMessage, {Map<String, dynamic>? extra}) {
    _analytics.logEvent(
      AnalyticsEvents.errorOccurred,
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        ...?extra,
      },
    );
  }
}
