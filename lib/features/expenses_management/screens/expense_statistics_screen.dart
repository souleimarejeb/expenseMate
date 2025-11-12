import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_analytics_provider.dart';
import '../widgets/expense_insights_card.dart';
import '../widgets/expense_stats_grid.dart';
import '../widgets/spending_trends_widget.dart';
import '../widgets/financial_tips_banner.dart';

class ExpenseStatisticsScreen extends StatefulWidget {
  const ExpenseStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseStatisticsScreen> createState() => _ExpenseStatisticsScreenState();
}

class _ExpenseStatisticsScreenState extends State<ExpenseStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Statistics',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.insights),
              text: 'Insights',
            ),
            Tab(
              icon: Icon(Icons.bar_chart),
              text: 'Statistics',
            ),
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Breakdown',
            ),
          ],
        ),
      ),
      body: Consumer<ExpenseAnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final expenses = provider.filteredExpenses;
          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          final totalAmount = provider.getTotalExpenses();
          final categorySpending = provider.getSpendingByCategory();
          final topCategory = provider.getTopSpendingCategory();
          final monthlyChange = provider.getMonthlyPercentChange();
          final dailyAvg = provider.getDailyAverage();
          final thisWeekExpenses = provider.getThisWeekExpenses();
          final thisMonthExpenses = provider.getMonthlyExpenses(DateTime.now());

          return TabBarView(
            controller: _tabController,
            children: [
              // Insights Tab
              _buildInsightsTab(
                totalAmount: totalAmount,
                dailyAvg: dailyAvg,
                expenses: expenses,
                topCategory: topCategory,
                monthlyChange: monthlyChange,
                categorySpending: categorySpending,
              ),
              
              // Statistics Tab
              _buildStatisticsTab(
                expenses: expenses,
                totalAmount: totalAmount,
                thisWeekExpenses: thisWeekExpenses,
                thisMonthExpenses: thisMonthExpenses,
                provider: provider,
              ),
              
              // Breakdown Tab
              _buildBreakdownTab(
                categorySpending: categorySpending,
                totalAmount: totalAmount,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInsightsTab({
    required double totalAmount,
    required double dailyAvg,
    required List expenses,
    required Map<String, dynamic> topCategory,
    required double monthlyChange,
    required Map<String, double> categorySpending,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ExpenseInsightsCard(
            totalExpenses: totalAmount,
            monthlyAverage: totalAmount,
            dailyAverage: dailyAvg,
            totalTransactions: expenses.length,
            topCategory: topCategory['categoryId'],
            topCategoryAmount: topCategory['amount'],
            percentChange: monthlyChange,
            categoryBreakdown: categorySpending,
          ),
          FinancialTipsBanner(
            totalExpenses: totalAmount,
            monthlyChange: monthlyChange,
            expenseCount: expenses.length,
            topCategory: topCategory['categoryId'],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab({
    required List expenses,
    required double totalAmount,
    required List thisWeekExpenses,
    required List thisMonthExpenses,
    required ExpenseAnalyticsProvider provider,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ExpenseStatsGrid(
            totalExpenses: expenses.length,
            averageExpense: expenses.isEmpty ? 0 : totalAmount / expenses.length,
            highestExpense: provider.getHighestExpense(),
            lowestExpense: provider.getLowestExpense(),
            thisWeekCount: thisWeekExpenses.length,
            thisWeekTotal: provider.getThisWeekTotal(),
            thisMonthCount: thisMonthExpenses.length,
            thisMonthTotal: provider.getThisMonthTotal(),
          ),
          const SizedBox(height: 16),
          _buildAdditionalStats(provider),
        ],
      ),
    );
  }

  Widget _buildBreakdownTab({
    required Map<String, double> categorySpending,
    required double totalAmount,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SpendingTrendsWidget(
            categorySpending: categorySpending,
            totalSpending: totalAmount,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats(ExpenseAnalyticsProvider provider) {
    final monthlyAvg = provider.getTotalExpenses() / 
        (provider.getMonthlyExpenses(DateTime.now()).isEmpty ? 1 : 
         provider.getMonthlyExpenses(DateTime.now()).length);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Additional Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            'Monthly Average',
            '\$${monthlyAvg.toStringAsFixed(2)}',
            Icons.calendar_month,
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Daily Average',
            '\$${provider.getDailyAverage().toStringAsFixed(2)}',
            Icons.today,
            Colors.green,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Monthly Change',
            '${provider.getMonthlyPercentChange().toStringAsFixed(1)}%',
            provider.getMonthlyPercentChange() >= 0 
                ? Icons.trending_up 
                : Icons.trending_down,
            provider.getMonthlyPercentChange() >= 0 
                ? Colors.red 
                : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add expenses to see statistics',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
