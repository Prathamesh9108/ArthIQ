import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class EnvConfig {
  final String appName;
  final String apiBaseUrl;
  final Environment environment;
  final bool enableDebugLogs;

  const EnvConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.environment,
    this.enableDebugLogs = true,
  });

  static EnvConfig? _instance;
  static EnvConfig get instance {
    _instance ??= const EnvConfig(
      appName: 'ArthIQ Dev',
      apiBaseUrl: 'http://localhost:5000/api',
      environment: Environment.development,
      enableDebugLogs: true,
    );
    return _instance!;
  }

  static void initialize({
    required Environment environment,
    String? apiBaseUrl,
  }) {
    switch (environment) {
      case Environment.development:
        // Android Emulator uses 10.0.2.2 to access host machine; Windows/Web uses localhost
        final defaultDevUrl = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            ? 'http://10.0.2.2:5000/api'
            : 'http://localhost:5000/api';
        _instance = EnvConfig(
          appName: 'ArthIQ Dev',
          apiBaseUrl: apiBaseUrl ?? defaultDevUrl,
          environment: Environment.development,
          enableDebugLogs: true,
        );
        break;
      case Environment.staging:
        _instance = EnvConfig(
          appName: 'ArthIQ Staging',
          apiBaseUrl: apiBaseUrl ?? 'https://api-stage.arthiq.io/v1',
          environment: Environment.staging,
          enableDebugLogs: true,
        );
        break;
      case Environment.production:
        _instance = EnvConfig(
          appName: 'ArthIQ',
          apiBaseUrl: apiBaseUrl ?? 'https://api.arthiq.io/v1',
          environment: Environment.production,
          enableDebugLogs: false,
        );
        break;
    }
  }
}
