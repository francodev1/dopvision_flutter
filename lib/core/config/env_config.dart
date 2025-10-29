// lib/core/config/env_config.dart
import 'package:flutter/foundation.dart';

/// 🔧 Configuração de variáveis de ambiente
/// 
/// Centraliza todas as variáveis de ambiente e configurações da aplicação.
/// Usa --dart-define para injetar valores em tempo de build.
class EnvConfig {
  // Singleton pattern
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  // 🔥 Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'dopvision-c384b', // Seu projeto atual
  );
  
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: '',
  );
  
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );

  // 🤖 OpenAI Configuration
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  static const String openaiOrgId = String.fromEnvironment(
    'OPENAI_ORG_ID',
    defaultValue: '',
  );

  // 🔗 n8n Webhooks Configuration
  static const String n8nBaseUrl = String.fromEnvironment(
    'N8N_BASE_URL',
    defaultValue: '',
  );
  
  static const String n8nApiKey = String.fromEnvironment(
    'N8N_API_KEY',
    defaultValue: '',
  );
  
  static const String n8nWebhookCampaignSync = String.fromEnvironment(
    'N8N_WEBHOOK_CAMPAIGN_SYNC',
    defaultValue: '/webhook/campaign-sync',
  );
  
  static const String n8nWebhookAiAnalysis = String.fromEnvironment(
    'N8N_WEBHOOK_AI_ANALYSIS',
    defaultValue: '/webhook/ai-analysis',
  );
  
  static const String n8nWebhookAlerts = String.fromEnvironment(
    'N8N_WEBHOOK_ALERTS',
    defaultValue: '/webhook/alerts',
  );

  // 📊 Sentry Configuration
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // 🌐 API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dopvision.com',
  );
  
  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  // 🌍 Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // 🚩 Feature Flags
  static const bool enableAIInsights = bool.fromEnvironment(
    'ENABLE_AI_INSIGHTS',
    defaultValue: true,
  );
  
  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: true,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  static const bool enableCrashReports = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTS',
    defaultValue: true,
  );

  // 🔍 Computed properties
  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  
  // URLs computadas para n8n
  String get n8nCampaignSyncUrl => '$n8nBaseUrl$n8nWebhookCampaignSync';
  String get n8nAiAnalysisUrl => '$n8nBaseUrl$n8nWebhookAiAnalysis';
  String get n8nAlertsUrl => '$n8nBaseUrl$n8nWebhookAlerts';

  /// 🔍 Valida se as configurações críticas estão presentes
  void validate() {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────┐');
      print('│  🔧 DoPVision Environment Configuration │');
      print('├─────────────────────────────────────────┤');
      print('│  Environment: $environment');
      print('│  🔥 Firebase Project: $firebaseProjectId');
      print('│  🤖 OpenAI: ${openaiApiKey.isNotEmpty ? "✅ Configured" : "❌ Missing"}');
      print('│  🔗 n8n URL: ${n8nBaseUrl.isNotEmpty ? "✅ Configured" : "❌ Missing"}');
      print('│  📊 Sentry: ${sentryDsn.isNotEmpty ? "✅ Configured" : "❌ Missing"}');
      print('├─────────────────────────────────────────┤');
      print('│  Feature Flags:');
      print('│  • AI Insights: ${enableAIInsights ? "✅" : "❌"}');
      print('│  • Offline Mode: ${enableOfflineMode ? "✅" : "❌"}');
      print('│  • Analytics: ${enableAnalytics ? "✅" : "❌"}');
      print('│  • Crash Reports: ${enableCrashReports ? "✅" : "❌"}');
      print('└─────────────────────────────────────────┘');
    }

    // ⚠️ Validações críticas para produção
    if (isProduction) {
      assert(firebaseApiKey.isNotEmpty, '❌ Firebase API Key is required in production');
      assert(firebaseAppId.isNotEmpty, '❌ Firebase App ID is required in production');
      assert(openaiApiKey.isNotEmpty, '❌ OpenAI API Key is required in production');
      assert(sentryDsn.isNotEmpty, '❌ Sentry DSN is required in production');
      assert(n8nBaseUrl.isNotEmpty, '❌ n8n Base URL is required in production');
    }
  }

  /// 📋 Retorna um Map com todas as configurações (para debugging)
  Map<String, dynamic> toJson() => {
    'environment': environment,
    'firebaseProjectId': firebaseProjectId,
    'hasOpenAIKey': openaiApiKey.isNotEmpty,
    'hasN8nUrl': n8nBaseUrl.isNotEmpty,
    'hasSentryDsn': sentryDsn.isNotEmpty,
    'features': {
      'aiInsights': enableAIInsights,
      'offlineMode': enableOfflineMode,
      'analytics': enableAnalytics,
      'crashReports': enableCrashReports,
    },
  };
}
