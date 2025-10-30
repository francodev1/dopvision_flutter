import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../shared/theme/app_theme.dart';

/// Tela de Política de Privacidade (LGPD compliant)
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        backgroundColor: AppTheme.bgDarkSecondary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                icon: CupertinoIcons.shield_lefthalf_fill,
                title: '1. Dados Coletados',
                content:
                    'Coletamos apenas os dados essenciais para o funcionamento do DoPVision:\n\n'
                    '• Email: Para autenticação e comunicação\n'
                    '• Nome: Para personalização da experiência\n'
                    '• Dados de clientes e vendas: Inseridos voluntariamente por você\n'
                    '• Logs de acesso: Para segurança e auditoria\n\n'
                    'Não coletamos dados sensíveis sem seu consentimento explícito.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.lock_shield,
                title: '2. Como Usamos Seus Dados',
                content:
                    '• Autenticação: Validar seu acesso à plataforma\n'
                    '• Funcionalidades: Gerenciar clientes, campanhas e vendas\n'
                    '• Segurança: Detectar atividades suspeitas\n'
                    '• Melhorias: Análises anônimas para aprimorar o app\n\n'
                    'Nunca vendemos ou compartilhamos seus dados com terceiros sem autorização.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.checkmark_shield,
                title: '3. Seus Direitos (LGPD)',
                content:
                    'Você tem direito a:\n\n'
                    '• Acesso: Ver todos os dados que temos sobre você\n'
                    '• Correção: Atualizar dados incorretos\n'
                    '• Exclusão: Deletar sua conta e todos os dados\n'
                    '• Portabilidade: Exportar seus dados\n'
                    '• Revogação: Retirar consentimento a qualquer momento\n\n'
                    'Para exercer seus direitos, acesse Configurações > Privacidade.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.timer,
                title: '4. Retenção de Dados',
                content:
                    '• Dados de conta: Mantidos enquanto sua conta estiver ativa\n'
                    '• Dados de vendas: Retidos por até 5 anos (obrigação fiscal)\n'
                    '• Logs de acesso: Retidos por 6 meses\n'
                    '• Após exclusão: Dados são anonimizados ou deletados em até 30 dias',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.lock_fill,
                title: '5. Segurança',
                content:
                    'Implementamos medidas técnicas e organizacionais:\n\n'
                    '• Criptografia: Dados sensíveis criptografados em trânsito (HTTPS) e em repouso\n'
                    '• Autenticação: Firebase Authentication com tokens seguros\n'
                    '• Isolamento: Seus dados são isolados de outros usuários\n'
                    '• Auditoria: Logs de acesso e alterações\n'
                    '• Backups: Backups diários com criptografia',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.globe,
                title: '6. Compartilhamento',
                content:
                    'Compartilhamos dados apenas quando:\n\n'
                    '• Você autoriza explicitamente\n'
                    '• Exigido por lei ou ordem judicial\n'
                    '• Para provedores de infraestrutura (Google Cloud/Firebase) com DPA assinado',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.person_2,
                title: '7. Cookies e Rastreamento',
                content:
                    'Usamos apenas cookies essenciais:\n\n'
                    '• Token de autenticação: Para manter sua sessão\n'
                    '• Preferências: Tema, idioma, configurações\n\n'
                    'Não usamos cookies de rastreamento ou publicidade.',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.arrow_clockwise,
                title: '8. Atualizações',
                content:
                    'Esta política pode ser atualizada periodicamente. '
                    'Você será notificado de mudanças significativas.\n\n'
                    'Última atualização: 30 de outubro de 2025',
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: CupertinoIcons.envelope,
                title: '9. Contato',
                content:
                    'Para questões sobre privacidade ou exercer seus direitos:\n\n'
                    'Email: privacidade@dopvision.com\n'
                    'DPO (Encarregado de Dados): dpo@dopvision.com',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
