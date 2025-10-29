// lib/core/services/openai_service.dart
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';
import '../exceptions/app_exception.dart';

/// 🤖 OpenAI Service
/// 
/// Integração com ChatGPT para:
/// - Geração de copies de anúncios
/// - Análise de campanhas
/// - Sugestões de otimização
/// - Insights de dados
class OpenAIService {
  OpenAIService() {
    _initialize();
  }

  void _initialize() {
    OpenAI.apiKey = EnvConfig.openaiApiKey;
    OpenAI.organization = EnvConfig.openaiOrgId;
  }

  // ============================================
  // 💬 Chat Completion
  // ============================================

  /// Envia mensagem e recebe resposta
  Future<String> chat({
    required String message,
    List<OpenAIChatCompletionChoiceMessageModel>? history,
    String model = 'gpt-4-turbo-preview',
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    try {
      AppLogger.logAI('chat_completion', {
        'model': model,
        'prompt_length': message.length,
      });

      final messages = [
        if (history != null) ...history,
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(message)],
        ),
      ];

      final completion = await OpenAI.instance.chat.create(
        model: model,
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      final response = completion.choices.first.message.content?.first.text ?? '';

      AppLogger.logAI('chat_response', {
        'response_length': response.length,
      });

      return response;
    } catch (e, stack) {
      AppLogger.error('❌ Erro no OpenAI', e, stack);
      throw AIException('Erro ao processar com OpenAI: $e');
    }
  }

  /// Chat com streaming
  Stream<String> chatStream({
    required String message,
    List<OpenAIChatCompletionChoiceMessageModel>? history,
    String model = 'gpt-4-turbo-preview',
    double temperature = 0.7,
  }) async* {
    try {
      final messages = [
        if (history != null) ...history,
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(message)],
        ),
      ];

      final stream = OpenAI.instance.chat.createStream(
        model: model,
        messages: messages,
        temperature: temperature,
      );

      // TODO: Fix type issues with dart_openai streaming
      await for (final chunk in stream) {
        final content = chunk.choices.first.delta.content;
        if (content != null && content.isNotEmpty) {
          // Workaround: converter para string diretamente
          yield content.toString();
        }
      }
    } catch (e, stack) {
      AppLogger.error('❌ Erro no stream do OpenAI', e, stack);
      throw AIException('Erro ao processar stream: $e');
    }
  }

  // ============================================
  // 📝 Funções Especializadas - DoPVision
  // ============================================

  /// Gera copy para anúncio
  Future<AdCopyResponse> generateAdCopy({
    required String productName,
    required String productDescription,
    required String targetAudience,
    required String platform, // facebook, instagram, google, etc
    String? tone, // profissional, casual, engraçado, etc
  }) async {
    final prompt = '''
Gere uma copy persuasiva para anúncio de tráfego pago:

**Produto/Serviço:** $productName
**Descrição:** $productDescription
**Público-Alvo:** $targetAudience
**Plataforma:** $platform
${tone != null ? '**Tom:** $tone' : ''}

Gere:
1. Título principal (chamativo, max 40 caracteres)
2. Descrição (persuasiva, max 90 caracteres)
3. Call-to-Action (direto, max 20 caracteres)
4. 3 variações do título
5. 3 hashtags relevantes

Formato JSON:
{
  "mainTitle": "...",
  "description": "...",
  "cta": "...",
  "titleVariations": ["...", "...", "..."],
  "hashtags": ["#...", "#...", "#..."]
}
''';

    await chat(
      message: prompt,
      model: 'gpt-4-turbo-preview',
      temperature: 0.8,
    );

    // TODO: Implementar parsing do JSON da resposta
    // Por enquanto retornando placeholder
    return AdCopyResponse(
      mainTitle: 'Título gerado',
      description: 'Descrição gerada',
      cta: 'CTA gerado',
      titleVariations: ['V1', 'V2', 'V3'],
      hashtags: ['#hashtag1', '#hashtag2', '#hashtag3'],
    );
  }

  /// Analisa performance de campanha
  Future<String> analyzeCampaign({
    required Map<String, dynamic> campaignData,
    required Map<String, dynamic> metricsData,
  }) async {
    final prompt = '''
Analise a performance desta campanha de tráfego pago:

**Dados da Campanha:**
${_formatJson(campaignData)}

**Métricas:**
${_formatJson(metricsData)}

Forneça:
1. Análise geral da performance
2. Pontos fortes
3. Pontos de atenção
4. 3 sugestões práticas de otimização
5. Previsão de resultados se aplicar as sugestões
''';

    return await chat(
      message: prompt,
      model: 'gpt-4-turbo-preview',
      temperature: 0.5,
      maxTokens: 1500,
    );
  }

  /// Sugere segmentação de público
  Future<String> suggestAudienceSegmentation({
    required String productType,
    required String businessNiche,
    String? currentAudience,
  }) async {
    final prompt = '''
Sugira segmentações de público para tráfego pago:

**Tipo de Produto:** $productType
**Nicho:** $businessNiche
${currentAudience != null ? '**Público Atual:** $currentAudience' : ''}

Forneça:
1. 3 segmentações detalhadas (demografia, interesses, comportamento)
2. Estimativa de tamanho de cada público
3. Melhor plataforma para cada segmentação
4. Budget sugerido inicial
''';

    return await chat(
      message: prompt,
      model: 'gpt-4-turbo-preview',
      temperature: 0.6,
      maxTokens: 1200,
    );
  }

  /// Gera insights de dados
  Future<String> generateInsights({
    required String metricType, // vendas, leads, roi, etc
    required List<Map<String, dynamic>> dataPoints,
  }) async {
    final prompt = '''
Analise estes dados de $metricType e gere insights acionáveis:

**Dados:**
${dataPoints.map((d) => _formatJson(d)).join('\n')}

Forneça:
1. Tendências identificadas
2. Padrões relevantes
3. Anomalias ou oportunidades
4. Recomendações estratégicas
''';

    return await chat(
      message: prompt,
      model: 'gpt-4-turbo-preview',
      temperature: 0.4,
      maxTokens: 1000,
    );
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  String _formatJson(Map<String, dynamic> data) {
    return data.entries.map((e) => '- ${e.key}: ${e.value}').join('\n');
  }
}

// ============================================
// 📋 Response Models
// ============================================

class AdCopyResponse {
  final String mainTitle;
  final String description;
  final String cta;
  final List<String> titleVariations;
  final List<String> hashtags;

  AdCopyResponse({
    required this.mainTitle,
    required this.description,
    required this.cta,
    required this.titleVariations,
    required this.hashtags,
  });
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});
