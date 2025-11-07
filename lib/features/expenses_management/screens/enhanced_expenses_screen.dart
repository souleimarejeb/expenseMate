import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/services/advanced_analytics_service.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';
import 'expense_detail_screen.dart';

class EnhancedExpensesScreen extends StatefulWidget {
  const EnhancedExpensesScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedExpensesScreen> createState() => _EnhancedExpensesScreenState();
}

class _EnhancedExpensesScreenState extends State<EnhancedExpensesScreen> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final AdvancedAnalyticsService _analyticsService = AdvancedAnalyticsService();
  

  bool _showSearchBar = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _spendingTrends = [];
  List<Map<String, dynamic>> _categoryInsights = [];
  Map<String, dynamic> _predictions = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final expenseProvider = context.read<ExpenseProvider>();
    await expenseProvider.initialize();
    await _loadAnalytics();
    _animationController.forward();
  }

  Future<void> _loadAnalytics() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    try {
      final trends = await _analyticsService.getSpendingTrends(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      final insights = await _analyticsService.getCategoryInsights(
        startDate: thirtyDaysAgo,
        endDate: now,
      );
      final predictions = await _analyticsService.predictNextMonthExpenses();
      
      if (mounted) {
        setState(() {
          _spendingTrends = trends;
          _categoryInsights = insights;
          _predictions = predictions;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildEnhancedAppBar(expenseProvider),
                  if (_showSearchBar) _buildSearchBar(),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildExpensesList(expenseProvider),
                  _buildAnalyticsView(),
                  _buildInsightsView(expenseProvider),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildSmartFAB(expenseProvider),
        );
      },
    );
  }

  Widget _buildEnhancedAppBar(ExpenseProvider expenseProvider) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Smart Expenses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'This Month',
                          '\$${expenseProvider.totalAmount.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Predicted',
                          '\$${(_predictions['predicted_amount'] ?? 0.0).toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.list_alt), text: 'Expenses'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
      actions: [
        IconButton(
          icon: Icon(_showSearchBar ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearchBar = !_showSearchBar;
              if (!_showSearchBar) {
                _searchController.clear();
                _searchResults.clear();
              }
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'export':
                _exportData(context.read<ExpenseProvider>());
                break;
              case 'import':
                _importData();
                break;
              case 'analytics_report':
                _generateAnalyticsReport();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'export', child: Text('Export Data')),
            PopupMenuItem(value: 'import', child: Text('Import Data')),
            PopupMenuItem(value: 'analytics_report', child: Text('Generate Report')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search expenses with AI...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchResults.clear());
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _performAdvancedSearch,
        ),
      ),
    );
  }

  Future<void> _performAdvancedSearch(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults.clear());
      return;
    }

    try {
      final results = await _analyticsService.searchExpensesAdvanced(
        query: query,
        limit: 20,
      );
      
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      print('Search error: $e');
    }
  }

  Widget _buildExpensesList(ExpenseProvider expenseProvider) {
    final expenses = _searchResults.isNotEmpty ? _searchResults : expenseProvider.expenses;
    
    if (expenseProvider.isLoading && expenses.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (expenseProvider.error != null) {
      return _buildErrorState(expenseProvider);
    }

    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await expenseProvider.loadData();
        await _loadAnalytics();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _buildEnhancedExpenseCard(expense as Map<String, dynamic>, expenseProvider);
        },
      ),
    );
  }

  Widget _buildEnhancedExpenseCard(Map<String, dynamic> expense, ExpenseProvider expenseProvider) {
    final categories = expenseProvider.categories;
    final category = categories.firstWhere(
      (cat) => cat.id == (expense['categoryId'] ?? expense['categoryId']),
      orElse: () => ExpenseCategory(
        name: 'Unknown',
        description: '',
        icon: Icons.help_outline,
        color: Colors.grey,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToExpenseDetail(expense),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'expense-${expense['id']}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 28,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense['title'] ?? expense['title'] ?? 'Untitled',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (expense['relevance_score'] != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(expense['relevance_score'] * 10).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (expense['description'] != null && expense['description'].toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            expense['description'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-\$${(expense['amount'] ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(expense['date']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSpendingTrendChart(),
          SizedBox(height: 24),
          _buildCategoryBreakdownChart(),
          SizedBox(height: 24),
          _buildAnomaliesSection(),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendChart() {
    if (_spendingTrends.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trend (30 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spendingTrends.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['dailyTotal'] ?? 0.0).toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Color(0xFF667eea),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Color(0xFF667eea).withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart() {
    if (_categoryInsights.isEmpty) return SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _categoryInsights.take(6).map((category) {
                    return PieChartSectionData(
                      color: Color(category['colorValue'] ?? Colors.grey.value),
                      value: (category['totalAmount'] ?? 0.0).toDouble(),
                      title: '${(category['percentage'] ?? 0.0).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            ...(_categoryInsights.take(6).map((category) => 
              _buildCategoryLegendItem(category)
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegendItem(Map<String, dynamic> category) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Color(category['colorValue'] ?? Colors.grey.value),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              category['name'] ?? 'Unknown',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '\$${(category['totalAmount'] ?? 0.0).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Unusual Spending Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _analyticsService.detectSpendingAnomalies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No unusual spending patterns detected.',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }
                
                return Column(
                  children: snapshot.data!.take(3).map((anomaly) {
                    return _buildAnomalyItem(anomaly);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnomalyItem(Map<String, dynamic> anomaly) {
    IconData icon;
    Color color;
    String description;
    
    switch (anomaly['anomaly_type']) {
      case 'high_outlier':
        icon = Icons.trending_up;
        color = Colors.red;
        description = 'Unusually high expense';
        break;
      case 'moderate_outlier':
        icon = Icons.warning;
        color = Colors.orange;
        description = 'Above normal spending';
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
        description = 'Notable expense';
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anomaly['title'] ?? 'Unknown',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(anomaly['amount'] ?? 0.0).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsView(ExpenseProvider expenseProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPredictionsCard(),
          SizedBox(height: 16),
          _buildRecommendationsCard(),
          SizedBox(height: 16),
          _buildSpendingVelocityCard(),
        ],
      ),
    );
  }

  Widget _buildPredictionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'AI Predictions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_predictions.isNotEmpty) ...[
              _buildPredictionItem(
                'Next Month Spending',
                '\$${(_predictions['predicted_amount'] ?? 0.0).toStringAsFixed(2)}',
                'Based on ${_predictions['months_of_data']} months of data',
                Colors.blue,
              ),
              _buildPredictionItem(
                'Average Monthly',
                '\$${(_predictions['avg_total'] ?? 0.0).toStringAsFixed(2)}',
                'Historical average',
                Colors.green,
              ),
            ] else
              Text('Building prediction model...'),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String title, String value, String subtitle, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.trending_up, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Smart Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _analyticsService.getSpendingRecommendations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No recommendations available yet.',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }
                
                return Column(
                  children: snapshot.data!.take(3).map((recommendation) {
                    return _buildRecommendationItem(recommendation);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    IconData icon;
    Color color;
    
    switch (recommendation['recommendation_type']) {
      case 'reduce_spending':
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      case 'low_spending':
        icon = Icons.thumb_up;
        color = Colors.green;
        break;
      case 'monitor_closely':
        icon = Icons.visibility;
        color = Colors.orange;
        break;
      default:
        icon = Icons.check_circle;
        color = Colors.blue;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation['recommendation_text'] ?? 'No recommendation',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingVelocityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Spending Velocity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _analyticsService.getSpendingVelocity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'Calculating velocity...',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }
                
                final latest = snapshot.data!.first;
                return _buildVelocityItem(latest);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVelocityItem(Map<String, dynamic> velocity) {
    final percentChange = velocity['percent_change'] ?? 0.0;
    final isIncreasing = percentChange > 0;
    final color = isIncreasing ? Colors.red : Colors.green;
    final icon = isIncreasing ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isIncreasing ? 'Increasing' : 'Decreasing'} by ${percentChange.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  'Compared to last period',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(velocity['total'] ?? 0.0).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ExpenseProvider expenseProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error: ${expenseProvider.error}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => expenseProvider.loadData(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFAB(ExpenseProvider expenseProvider) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddExpense(expenseProvider),
      backgroundColor: Color(0xFF667eea),
      icon: Icon(Icons.add, color: Colors.white),
      label: Text(
        'Smart Add',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _navigateToAddExpense(ExpenseProvider expenseProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(),
      ),
    ).then((_) {
      expenseProvider.loadData();
      _loadAnalytics();
    });
  }

  void _navigateToExpenseDetail(Map<String, dynamic> expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expense: expense),
      ),
    ).then((_) {
      // Refresh data when returning from detail screen
      final expenseProvider = context.read<ExpenseProvider>();
      expenseProvider.loadData();
      _loadAnalytics();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    
    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Unknown';
    }
    
    return DateFormat('MMM dd').format(dateTime);
  }

  void _exportData(ExpenseProvider expenseProvider) {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Import functionality coming soon!')),
    );
  }

  void _generateAnalyticsReport() {
    // TODO: Generate PDF report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analytics report generation coming soon!')),
    );
  }
}