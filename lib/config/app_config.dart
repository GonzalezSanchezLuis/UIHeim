import 'package:flutter/foundation.dart';
import 'package:holi/config/development.dart' as development;
import 'package:holi/config/production.dart' as production;

String apiBaseUrl = '';
String currentEnvironment = '';

void configureApp(String env) {
  switch (env) {
    case 'DEVELOPMENT':
      if (kDebugMode) {
        currentEnvironment = development.environment;
        apiBaseUrl = development.baseUrl;
      }
      break;

    case 'PRODUCTION':
      currentEnvironment = production.environment;
      apiBaseUrl = production.baseUrl;
      break;

    default:
      currentEnvironment = development.environment;
      apiBaseUrl = development.baseUrl;
  }
}

String getWsUrl(String httpBaseUrl, String endPoint) {
  String wsBaseUrl;

  if (httpBaseUrl.startsWith("https://")) {
    wsBaseUrl = httpBaseUrl.replaceFirst('https://', 'wss://');
  } else if (httpBaseUrl.startsWith("http://")) {
    wsBaseUrl = httpBaseUrl.replaceFirst('http://', 'ws://');
  } else {
    throw Exception("URL BASE INAVLDA");
  }
  return "$wsBaseUrl$endPoint";
}
