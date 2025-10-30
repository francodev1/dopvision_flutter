import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';

/// Tela de Termos de Uso
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: AppTheme.bgDarkSecondary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: '1. Aceitação dos Termos',
                content:
                    'Ao usar o DoPVision, você concorda com estes Termos de Uso. '
                    'Se não concordar, não use o aplicativo.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '2. Uso do Serviço',
                content:
                    'O DoPVision é uma plataforma para gestão de clientes, campanhas e vendas. '
                    'Você concorda em:\n\n'
                    '• Usar o serviço apenas para fins legais\n'
                    '• Não tentar hackear ou comprometer o sistema\n'
                    '• Não compartilhar suas credenciais\n'
                    '• Manter seus dados atualizados e precisos\n'
                    '• Não usar o serviço para fins fraudulentos',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '3. Propriedade dos Dados',
                content:
                    'Você mantém propriedade total dos seus dados. '
                    'Concedemos apenas licença para processar seus dados para fornecer o serviço.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '4. Responsabilidades',
                content:
                    'Você é responsável por:\n\n'
                    '• Manter a segurança da sua conta\n'
                    '• Backup dos seus dados\n'
                    '• Conformidade com leis aplicáveis (LGPD, tributação, etc.)\n'
                    '• Veracidade dos dados inseridos',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '5. Disponibilidade',
                content:
                    'Nos esforçamos para manter o serviço disponível 24/7, mas não garantimos '
                    '100% de uptime. Podem ocorrer manutenções programadas.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '6. Modificações',
                content:
                    'Podemos modificar estes termos a qualquer momento. '
                    'Você será notificado de mudanças significativas.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '7. Cancelamento',
                content:
                    'Você pode cancelar sua conta a qualquer momento em Configurações > Conta. '
                    'Após o cancelamento, seus dados serão deletados conforme a Política de Privacidade.',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '8. Limitação de Responsabilidade',
                content:
                    'O DoPVision não se responsabiliza por:\n\n'
                    '• Perda de dados devido a ações do usuário\n'
                    '• Decisões de negócio baseadas nos dados\n'
                    '• Problemas de conectividade ou dispositivos',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '9. Lei Aplicável',
                content:
                    'Estes termos são regidos pelas leis brasileiras. '
                    'Foro: Comarca de [Sua Cidade].',
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '10. Contato',
                content:
                    'Dúvidas sobre os termos?\n\n'
                    'Email: suporte@dopvision.com',
              ),
              const SizedBox(height: 40),
              const Text(
                'Última atualização: 30 de outubro de 2025',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppTheme.textMuted,
            letterSpacing: -0.3,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
