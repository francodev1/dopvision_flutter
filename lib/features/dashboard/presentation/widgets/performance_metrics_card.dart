import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../providers/performance_metrics_provider.dart';
import '../../domain/performance_metrics.dart';

class PerformanceMetricsCard extends ConsumerWidget {
  final String clientId;
  
  const PerformanceMetricsCard({
    required this.clientId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(latestClientMetricsProvider(clientId));
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up, color: AppTheme.warning, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Métricas de Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                onPressed: () {
                  // TODO: Abrir modal para adicionar/editar métricas
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Content
          metricsAsync.when(
            data: (metrics) {
              if (metrics == null) {
                return _EmptyState();
              }
              return _MetricsContent(metrics: metrics, isMobile: isMobile);
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Erro ao carregar métricas',
                style: TextStyle(color: AppTheme.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma métrica registrada',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no + para adicionar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsContent extends StatelessWidget {
  final PerformanceMetrics metrics;
  final bool isMobile;
  
  const _MetricsContent({
    required this.metrics,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final percentFormat = NumberFormat.decimalPattern('pt_BR');
    
    return Column(
      children: [
        // Período
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Período: ${DateFormat('MMMM yyyy', 'pt_BR').format(metrics.period)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Grid de Métricas
        GridView.count(
          crossAxisCount: isMobile ? 2 : 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.2 : 1.5,
          children: [
            _MetricTile(
              label: 'ROI',
              value: '${metrics.roi >= 0 ? '+' : ''}${percentFormat.format(metrics.roi)}%',
              color: metrics.roi >= 0 ? AppTheme.success : AppTheme.danger,
              icon: Icons.monetization_on,
            ),
            _MetricTile(
              label: 'ROAS',
              value: '${percentFormat.format(metrics.roas)}x',
              color: AppTheme.primary,
              icon: Icons.show_chart,
            ),
            _MetricTile(
              label: 'CPC',
              value: currencyFormat.format(metrics.investmentAmount / (metrics.clicks > 0 ? metrics.clicks : 1)),
              color: AppTheme.warning,
              icon: Icons.mouse,
            ),
            _MetricTile(
              label: 'CPL',
              value: currencyFormat.format(metrics.cpl),
              color: AppTheme.secondary,
              icon: Icons.person_add,
            ),
            _MetricTile(
              label: 'CPA',
              value: currencyFormat.format(metrics.cpa),
              color: AppTheme.danger,
              icon: Icons.shopping_cart,
            ),
            _MetricTile(
              label: 'CTR',
              value: '${percentFormat.format(metrics.ctr)}%',
              color: AppTheme.success,
              icon: Icons.ads_click,
            ),
            _MetricTile(
              label: 'AOV',
              value: currencyFormat.format(metrics.aov),
              color: AppTheme.warning,
              icon: Icons.attach_money,
            ),
            _MetricTile(
              label: 'LTV',
              value: currencyFormat.format(metrics.ltv),
              color: AppTheme.primary,
              icon: Icons.trending_up,
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Resumo de Investimento e Receita
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.2),
                AppTheme.secondary.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                icon: Icons.payments,
                label: 'Investido',
                value: currencyFormat.format(metrics.investmentAmount),
                color: AppTheme.danger,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _SummaryItem(
                icon: Icons.account_balance_wallet,
                label: 'Receita',
                value: currencyFormat.format(metrics.revenue),
                color: AppTheme.success,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
