import 'package:get_it/get_it.dart';
import '../analytics/analytics_service.dart';
import '../analytics/analytics_manager.dart';
import '../analytics/firebase_analytics_service.dart';

final GetIt locator = GetIt.instance;

void setupAnalytics() {
  // Registrar servicios
  locator.registerLazySingleton<IAnalyticsService>(() => AnalyticsManager([
        FirebaseAnalyticsService(),
        // Aquí puedes agregar más servicios:
        // MixpanelService(),
        // AmplitudeService(),
      ]));

  // Inicializar (opcional)
  final analytics = locator<IAnalyticsService>();
  analytics.setAnalyticsEnabled(true);
}

// Función de conveniencia
IAnalyticsService get analytics => locator<IAnalyticsService>();
