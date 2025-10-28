import 'client.dart';
import 'campaign.dart';
import 'sale.dart';

class DashboardMetrics {
  final double totalRevenue;
  final double totalInvested;
  final double roi;
  final double conversionRate;
  final double averageTicket;
  final int totalImpressions;
  final int totalClicks;
  final int totalLeads;
  final double ctr;
  final double cpm;
  final double cpl;

  DashboardMetrics({
    this.totalRevenue = 0.0,
    this.totalInvested = 0.0,
    this.roi = 0.0,
    this.conversionRate = 0.0,
    this.averageTicket = 0.0,
    this.totalImpressions = 0,
    this.totalClicks = 0,
    this.totalLeads = 0,
    this.ctr = 0.0,
    this.cpm = 0.0,
    this.cpl = 0.0,
  });
}

class ClientDashboard {
  final Client client;
  final List<Campaign> campaigns;
  final List<Sale> sales;
  final DashboardMetrics metrics;

  ClientDashboard({
    required this.client,
    required this.campaigns,
    required this.sales,
    required this.metrics,
  });
}
