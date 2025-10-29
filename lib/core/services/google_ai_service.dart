// lib/core/services/google_ai_service.dart
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../utils/logger.dart';
import '../exceptions/app_exception.dart';

/// 🤖 Google AI Service (Gemini)
/// 
/// Integração com Gemini para:
/// - Alternativa ao ChatGPT
/// - Análise de imagens
/// - Geração de conteúdo
class GoogleAIService {
  late final GenerativeModel _model;

  GoogleAIService({String model = 'gemini-pro'}) {
    _initialize(model);
  }

  void _initialize(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: EnvConfig.geminiApiKey,
    );
  }

  // ============================================
  // 💬 Text Generation
  // ============================================

  /// Gera conteúdo de texto
  Future<String> generateContent({
    required String prompt,
    double temperature = 0.7,
  }) async {
    try {
      AppLogger.logAI('gemini_generate', {
        'prompt_length': prompt.length,
      });

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final text = response.text ?? '';

      AppLogger.logAI('gemini_response', {
        'response_length': text.length,
      });

      return text;
    } catch (e, stack) {
      AppLogger.error('❌ Erro no Google AI', e, stack);
      throw AIException('Erro ao processar com Gemini: $e');
    }
  }

  /// Geração com streaming
  Stream<String> generateContentStream({
    required String prompt,
  }) async* {
    try {
      final content = [Content.text(prompt)];
      final stream = _model.generateContentStream(content);

      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e, stack) {
      AppLogger.error('❌ Erro no stream do Gemini', e, stack);
      throw AIException('Erro ao processar stream: $e');
    }
  }

  /// Chat multi-turno
  Future<String> chat({
    required List<ChatMessage> history,
    required String message,
  }) async {
    try {
      final chatSession = _model.startChat(
        history: history.map((msg) {
          return Content(
            msg.role,
            [TextPart(msg.content)],
          );
        }).toList(),
      );

      final response = await chatSession.sendMessage(
        Content.text(message),
      );

      return response.text ?? '';
    } catch (e, stack) {
      AppLogger.error('❌ Erro no chat do Gemini', e, stack);
      throw AIException('Erro no chat: $e');
    }
  }

  // ============================================
  // 🖼️ Vision (gemini-pro-vision)
  // ============================================

  /// Analisa imagem
  Future<String> analyzeImage({
    required List<int> imageBytes,
    required String prompt,
  }) async {
    try {
      // Usar modelo com visão
      final visionModel = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: EnvConfig.geminiApiKey,
      );

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];

      final response = await visionModel.generateContent(content);
      return response.text ?? '';
    } catch (e, stack) {
      AppLogger.error('❌ Erro na análise de imagem', e, stack);
      throw AIException('Erro ao analisar imagem: $e');
    }
  }

  // ============================================
  // 📝 Funções Especializadas - DoPVision
  // ============================================

  /// Gera copy para anúncio
  Future<String> generateAdCopy({
    required String productName,
    required String productDescription,
    required String targetAudience,
    required String platform,
    String? tone,
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
''';

    return await generateContent(prompt: prompt, temperature: 0.8);
  }

  /// Analisa criativo de anúncio (imagem)
  Future<String> analyzeAdCreative({
    required List<int> imageBytes,
  }) async {
    return await analyzeImage(
      imageBytes: imageBytes,
      prompt: '''
Analise este criativo de anúncio de tráfego pago:

Avalie:
1. Qualidade visual e composição
2. Clareza da mensagem
3. Apelo emocional
4. Call-to-action visível
5. Adequação para plataformas de ads

Forneça:
- Nota de 0-10
- Pontos fortes
- Pontos de melhoria
- Sugestões de otimização
''',
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
${_formatData(campaignData)}

**Métricas:**
${_formatData(metricsData)}

Forneça:
1. Análise geral da performance
2. Pontos fortes
3. Pontos de atenção
4. 3 sugestões práticas de otimização
5. Previsão de resultados
''';

    return await generateContent(prompt: prompt, temperature: 0.5);
  }

  /// Gera insights de dados
  Future<String> generateInsights({
    required String metricType,
    required List<Map<String, dynamic>> dataPoints,
  }) async {
    final prompt = '''
Analise estes dados de $metricType e gere insights:

**Dados:**
${dataPoints.map(_formatData).join('\n---\n')}

Forneça:
1. Tendências identificadas
2. Padrões relevantes
3. Anomalias ou oportunidades
4. Recomendações estratégicas
''';

    return await generateContent(prompt: prompt, temperature: 0.4);
  }

  /// Sugere melhorias em texto
  Future<String> improveText({
    required String text,
    required String context, // copy de anúncio, email, post, etc
  }) async {
    final prompt = '''
Melhore este texto de $context:

**Texto Original:**
$text

Forneça:
1. Versão melhorada
2. Explicação das mudanças
3. 2 variações alternativas
''';

    return await generateContent(prompt: prompt, temperature: 0.7);
  }

  // ============================================
  // 🛠️ Utilitários
  // ============================================

  String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '- ${e.key}: ${e.value}').join('\n');
  }
}

// ============================================
// 📋 Helper Classes
// ============================================

class ChatMessage {
  final String role; // 'user' ou 'model'
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });
}

// ============================================
// 🎯 Riverpod Provider
// ============================================

final googleAIServiceProvider = Provider<GoogleAIService>((ref) {
  return GoogleAIService();
});
