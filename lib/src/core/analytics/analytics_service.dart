abstract class IAnalyticsService {
  /// Registrar un evento con parámetros opcionales
  void logEvent(String name, {Map<String, dynamic>? parameters});

  /// Registrar vista de pantalla
  void logScreenView(String screenName, {Map<String, dynamic>? parameters});

  /// Establecer ID de usuario
  void setUserId(String? userId);

  /// Establecer propiedades del usuario
  void setUserProperties(Map<String, dynamic> properties);

  /// Habilitar/deshabilitar analytics (GDPR)
  void setAnalyticsEnabled(bool enabled);
}
