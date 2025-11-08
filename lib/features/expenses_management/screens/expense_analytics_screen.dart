import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:intl/intl.dart';import 'package:provider/provider.dart';import 'package:provider/provider.dart';

import '../../../core/models/expense.dart';

import '../../../core/models/expense_category.dart';import 'package:intl/intl.dart';import 'package:fl_chart/fl_chart.dart';

import '../providers/expense_analytics_provider.dart';

import 'add_edit_expense_screen.dart';import '../../../core/models/expense.dart';import 'package:intl/intl.dart';



class ExpenseAnalyticsScreen extends StatefulWidget {import '../../../core/models/expense_category.dart';import '../../../core/models/expense.dart';

  const ExpenseAnalyticsScreen({Key? key}) : super(key: key);

import '../providers/expense_analytics_provider.dart';import '../../../core/models/expense_category.dart';

  @override

  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();import '../widgets/expense_monthly_chart.dart';import '../providers/expense_analytics_provider.dart';

}

import '../widgets/expense_category_chart.dart';import 'add_edit_expense_screen.dart';

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen>

    with SingleTickerProviderStateMixin {import '../widgets/expense_stats_card.dart';

  late TabController _tabController;

  DateTime selectedMonth = DateTime.now();import '../widgets/expense_trend_card.dart';class ExpenseAnalyticsScreen extends StatefulWidget {



  @overrideimport 'add_edit_expense_screen.dart';  const ExpenseAnalyticsScreen({Key? key}) : super(key: key);

  void initState() {

    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {class ExpenseAnalyticsScreen extends StatefulWidget {  @override

      context.read<ExpenseAnalyticsProvider>().initialize();

    });  const ExpenseAnalyticsScreen({Key? key}) : super(key: key);  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();

  }

}

  @override

  void dispose() {  @override

    _tabController.dispose();

    super.dispose();  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen>

  }

}    with SingleTickerProviderStateMixin {

  @override

  Widget build(BuildContext context) {  late TabController _tabController;

    return Scaffold(

      backgroundColor: const Color(0xFFF8F9FA),class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen>  DateTime selectedMonth = DateTime.now();

      appBar: AppBar(

        backgroundColor: Colors.white,    with SingleTickerProviderStateMixin {  String selectedCategory = 'All';

        elevation: 0,

        title: const Text(  late TabController _tabController;

          'Expense Analytics',

          style: TextStyle(  DateTime selectedMonth = DateTime.now();  @override

            color: Colors.black87,

            fontSize: 24,  void initState() {

            fontWeight: FontWeight.w600,

          ),  @override    super.initState();

        ),

        centerTitle: true,  void initState() {    _tabController = TabController(length: 4, vsync: this);

      ),

      body: Consumer<ExpenseAnalyticsProvider>(    super.initState();    WidgetsBinding.instance.addPostFrameCallback((_) {

        builder: (context, provider, child) {

          if (provider.isLoading) {    _tabController = TabController(length: 4, vsync: this);      context.read<ExpenseAnalyticsProvider>().initialize();

            return const Center(

              child: CircularProgressIndicator(color: Colors.black),    WidgetsBinding.instance.addPostFrameCallback((_) {      context.read<ExpenseAnalyticsProvider>().loadMonthlyData(selectedMonth);

            );

          }      context.read<ExpenseAnalyticsProvider>().initialize();    });



          if (provider.error != null) {      context.read<ExpenseAnalyticsProvider>().loadMonthlyData(selectedMonth);  }

            return Center(

              child: Column(    });

                mainAxisAlignment: MainAxisAlignment.center,

                children: [  }  @override

                  const Icon(Icons.error_outline, size: 64, color: Colors.red),

                  const SizedBox(height: 16),  void dispose() {

                  Text(

                    'Error: ${provider.error}',  @override    _tabController.dispose();

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: Colors.red, fontSize: 16),  void dispose() {    super.dispose();

                  ),

                  const SizedBox(height: 16),    _tabController.dispose();  }

                  ElevatedButton(

                    onPressed: () => provider.loadData(),    super.dispose();

                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.black,  }  @override

                      foregroundColor: Colors.white,

                    ),  Widget build(BuildContext context) {

                    child: const Text('Retry'),

                  ),  @override    return Scaffold(

                ],

              ),  Widget build(BuildContext context) {      backgroundColor: const Color(0xFFF8F9FA),

            );

          }    return Scaffold(      appBar: _buildAppBar(),



          return Column(      backgroundColor: const Color(0xFFF8F9FA),      body: Consumer<ExpenseAnalyticsProvider>(

            children: [

              _buildOverviewStats(provider),      appBar: _buildAppBar(),        builder: (context, provider, child) {

              _buildTabBar(),

              Expanded(      body: Consumer<ExpenseAnalyticsProvider>(          if (provider.isLoading) {

                child: TabBarView(

                  controller: _tabController,        builder: (context, provider, child) {            return const Center(

                  children: [

                    _buildOverviewTab(provider),          if (provider.isLoading) {              child: CircularProgressIndicator(

                    _buildExpensesTab(provider),

                  ],            return const Center(                color: Colors.black,

                ),

              ),              child: CircularProgressIndicator(color: Colors.black),              ),

            ],

          );            );            );

        },

      ),          }          }

      floatingActionButton: FloatingActionButton.extended(

        onPressed: () => _navigateToAddExpense(context),

        backgroundColor: Colors.black,

        foregroundColor: Colors.white,          if (provider.error != null) {          if (provider.error != null) {

        icon: const Icon(Icons.add),

        label: const Text('Add Expense'),            return _buildErrorState(provider);            return _buildErrorState(provider);

      ),

    );          }          }

  }



  Widget _buildOverviewStats(ExpenseAnalyticsProvider provider) {

    final totalAmount = provider.getTotalExpenses();          return Column(          return Column(

    final expenseCount = provider.getExpenseCount();

    final averageAmount = provider.getAverageExpenseAmount();            children: [            children: [



    return Container(              _buildMonthSelector(),              _buildMonthSelector(),

      padding: const EdgeInsets.all(16),

      child: Row(              _buildOverviewStats(provider),              _buildOverviewStats(provider),

        children: [

          Expanded(              _buildTabBar(),              _buildTabBar(),

            child: _buildStatCard(

              'Total Spent',              Expanded(              Expanded(

              '\$${totalAmount.toStringAsFixed(2)}',

              Icons.account_balance_wallet,                child: TabBarView(                child: TabBarView(

              Colors.blue,

            ),                  controller: _tabController,                  controller: _tabController,

          ),

          const SizedBox(width: 12),                  children: [                  children: [

          Expanded(

            child: _buildStatCard(                    _buildOverviewTab(provider),                    _buildOverviewTab(provider),

              'Expenses',

              '$expenseCount',                    _buildAnalyticsTab(provider),                    _buildAnalyticsTab(provider),

              Icons.receipt_long,

              Colors.green,                    _buildCategoriesTab(provider),                    _buildCategoriesTab(provider),

            ),

          ),                    _buildExpensesTab(provider),                    _buildExpensesTab(provider),

          const SizedBox(width: 12),

          Expanded(                  ],                  ],

            child: _buildStatCard(

              'Average',                ),                ),

              '\$${averageAmount.toStringAsFixed(2)}',

              Icons.trending_up,              ),              ),

              Colors.orange,

            ),            ],            ],

          ),

        ],          );          );

      ),

    );        },        },

  }

      ),      ),

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {

    return Container(      floatingActionButton: FloatingActionButton.extended(      floatingActionButton: FloatingActionButton.extended(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(        onPressed: () => _navigateToAddExpense(context),        onPressed: () => _navigateToAddExpense(context),

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),        backgroundColor: Colors.black,        backgroundColor: Colors.black,

        boxShadow: [

          BoxShadow(        foregroundColor: Colors.white,        foregroundColor: Colors.white,

            color: Colors.black.withOpacity(0.05),

            blurRadius: 10,        icon: const Icon(Icons.add),        icon: const Icon(Icons.add),

            offset: const Offset(0, 2),

          ),        label: const Text('Add Expense'),        label: const Text('Add Expense'),

        ],

      ),      ),      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,    );    );

        children: [

          Icon(icon, color: color, size: 24),  }  }

          const SizedBox(height: 12),

          Text(

            value,

            style: const TextStyle(  PreferredSizeWidget _buildAppBar() {  Widget _buildYearSelector() {

              fontSize: 18,

              fontWeight: FontWeight.bold,    return AppBar(    return Card(

            ),

          ),      backgroundColor: Colors.white,      child: Padding(

          Text(

            title,      elevation: 0,        padding: const EdgeInsets.all(16),

            style: TextStyle(

              fontSize: 12,      title: const Text(        child: Row(

              color: Colors.grey[600],

            ),        'Expense Analytics',          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          ),

        ],        style: TextStyle(          children: [

      ),

    );          color: Colors.black87,            const Text(

  }

          fontSize: 24,              'Analytics Year',

  Widget _buildTabBar() {

    return Container(          fontWeight: FontWeight.w600,              style: TextStyle(

      margin: const EdgeInsets.all(16),

      child: TabBar(        ),                fontSize: 16,

        controller: _tabController,

        labelColor: Colors.white,      ),                fontWeight: FontWeight.w600,

        unselectedLabelColor: Colors.black54,

        indicator: BoxDecoration(      centerTitle: true,              ),

          color: Colors.black,

          borderRadius: BorderRadius.circular(25),      actions: [            ),

        ),

        tabs: const [        IconButton(            DropdownButton<int>(

          Tab(text: 'Overview'),

          Tab(text: 'Expenses'),          onPressed: () => _showFilterDialog(context),              value: _selectedYear,

        ],

      ),          icon: const Icon(Icons.filter_list, color: Colors.black87),              items: List.generate(5, (index) {

    );

  }        ),                final year = DateTime.now().year - index;



  Widget _buildOverviewTab(ExpenseAnalyticsProvider provider) {      ],                return DropdownMenuItem(

    final categorySpending = provider.getSpendingByCategory();

        );                  value: year,

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),  }                  child: Text(year.toString()),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,                );

        children: [

          const Text(  Widget _buildErrorState(ExpenseAnalyticsProvider provider) {              }),

            'Category Breakdown',

            style: TextStyle(    return Center(              onChanged: (year) {

              fontSize: 20,

              fontWeight: FontWeight.bold,      child: Column(                if (year != null) {

            ),

          ),        mainAxisAlignment: MainAxisAlignment.center,                  setState(() => _selectedYear = year);

          const SizedBox(height: 16),

          _buildCategoryList(categorySpending, provider),        children: [                }

          const SizedBox(height: 20),

          _buildRecentExpenses(provider),          const Icon(Icons.error_outline, size: 64, color: Colors.red),              },

        ],

      ),          const SizedBox(height: 16),            ),

    );

  }          Text(          ],



  Widget _buildExpensesTab(ExpenseAnalyticsProvider provider) {            'Error: ${provider.error}',        ),

    final expenses = provider.filteredExpenses;

                textAlign: TextAlign.center,      ),

    return Column(

      children: [            style: const TextStyle(color: Colors.red, fontSize: 16),    );

        _buildExpenseFilters(provider),

        Expanded(          ),  }

          child: expenses.isEmpty

              ? _buildEmptyState()          const SizedBox(height: 16),

              : ListView.builder(

                  padding: const EdgeInsets.all(16),          ElevatedButton(  Widget _buildTotalSummaryCard(ExpenseProvider provider) {

                  itemCount: expenses.length,

                  itemBuilder: (context, index) {            onPressed: () => provider.loadData(),    return Card(

                    return _buildExpenseItem(expenses[index], provider);

                  },            style: ElevatedButton.styleFrom(      child: Padding(

                ),

        ),              backgroundColor: Colors.black,        padding: const EdgeInsets.all(20),

      ],

    );              foregroundColor: Colors.white,        child: Column(

  }

            ),          crossAxisAlignment: CrossAxisAlignment.start,

  Widget _buildCategoryList(Map<String, double> categorySpending, ExpenseAnalyticsProvider provider) {

    if (categorySpending.isEmpty) {            child: const Text('Retry'),          children: [

      return Container(

        height: 200,          ),            const Text(

        decoration: BoxDecoration(

          color: Colors.white,        ],              'Year Summary',

          borderRadius: BorderRadius.circular(16),

        ),      ),              style: TextStyle(

        child: const Center(

          child: Text('No expenses yet'),    );                fontSize: 18,

        ),

      );  }                fontWeight: FontWeight.bold,

    }

              ),

    final totalSpent = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

  Widget _buildMonthSelector() {            ),

    return Container(

      padding: const EdgeInsets.all(20),    return Container(            const SizedBox(height: 16),

      decoration: BoxDecoration(

        color: Colors.white,      padding: const EdgeInsets.all(16),            Row(

        borderRadius: BorderRadius.circular(16),

        boxShadow: [      child: Row(              children: [

          BoxShadow(

            color: Colors.black.withOpacity(0.05),        mainAxisAlignment: MainAxisAlignment.spaceBetween,                Expanded(

            blurRadius: 10,

            offset: const Offset(0, 2),        children: [                  child: _buildSummaryItem(

          ),

        ],          IconButton(                    'Total Spent',

      ),

      child: Column(            onPressed: () {                    NumberFormat.currency(symbol: '\$').format(provider.totalAmount),

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [              setState(() {                    Icons.trending_down,

          ...categorySpending.entries.map((entry) {

            final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0;                selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);                    Colors.red,

            final category = provider.categories.firstWhere(

              (cat) => cat.name == entry.key,              });                  ),

              orElse: () => ExpenseCategory(

                name: entry.key,              context.read<ExpenseAnalyticsProvider>().loadMonthlyData(selectedMonth);                ),

                description: '',

                icon: Icons.shopping_bag,            },                Expanded(

                color: Colors.grey,

                createdAt: DateTime.now(),            icon: const Icon(Icons.chevron_left),                  child: _buildSummaryItem(

                updatedAt: DateTime.now(),

              ),          ),                    'Transactions',

            );

          Text(                    provider.expenses.length.toString(),

            return Padding(

              padding: const EdgeInsets.symmetric(vertical: 8),            DateFormat('MMMM yyyy').format(selectedMonth),                    Icons.receipt,

              child: Row(

                children: [            style: const TextStyle(                    Colors.blue,

                  Container(

                    padding: const EdgeInsets.all(8),              fontSize: 20,                  ),

                    decoration: BoxDecoration(

                      color: category.color.withOpacity(0.1),              fontWeight: FontWeight.w600,                ),

                      borderRadius: BorderRadius.circular(8),

                    ),            ),              ],

                    child: Icon(

                      category.icon,          ),            ),

                      color: category.color,

                      size: 20,          IconButton(            const SizedBox(height: 16),

                    ),

                  ),            onPressed: () {            Row(

                  const SizedBox(width: 12),

                  Expanded(              setState(() {              children: [

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,                selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);                Expanded(

                      children: [

                        Text(              });                  child: _buildSummaryItem(

                          category.name,

                          style: const TextStyle(              context.read<ExpenseAnalyticsProvider>().loadMonthlyData(selectedMonth);                    'Avg per Month',

                            fontWeight: FontWeight.w500,

                          ),            },                    NumberFormat.currency(symbol: '\$').format(

                        ),

                        const SizedBox(height: 4),            icon: const Icon(Icons.chevron_right),                      provider.totalAmount / 12,

                        LinearProgressIndicator(

                          value: percentage / 100,          ),                    ),

                          backgroundColor: Colors.grey[200],

                          valueColor: AlwaysStoppedAnimation<Color>(category.color),        ],                    Icons.calendar_today,

                        ),

                      ],      ),                    Colors.green,

                    ),

                  ),    );                  ),

                  const SizedBox(width: 12),

                  Column(  }                ),

                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [                Expanded(

                      Text(

                        '\$${entry.value.toStringAsFixed(2)}',  Widget _buildOverviewStats(ExpenseAnalyticsProvider provider) {                  child: _buildSummaryItem(

                        style: const TextStyle(

                          fontWeight: FontWeight.bold,    final totalAmount = provider.getTotalExpenses();                    'Categories',

                          fontSize: 16,

                        ),    final expenseCount = provider.getExpenseCount();                    provider.expensesByCategory.keys.length.toString(),

                      ),

                      Text(    final averageAmount = provider.getAverageExpenseAmount();                    Icons.category,

                        '${percentage.toStringAsFixed(1)}%',

                        style: TextStyle(                    Colors.orange,

                          color: Colors.grey[600],

                          fontSize: 12,    return Container(                  ),

                        ),

                      ),      padding: const EdgeInsets.symmetric(horizontal: 16),                ),

                    ],

                  ),      child: Row(              ],

                ],

              ),        children: [            ),

            );

          }).toList(),          Expanded(          ],

        ],

      ),            child: _buildStatCard(        ),

    );

  }              'Total Spent',      ),



  Widget _buildRecentExpenses(ExpenseAnalyticsProvider provider) {              '\$${totalAmount.toStringAsFixed(2)}',    );

    final recentExpenses = provider.recentExpenses.take(5).toList();

              Icons.account_balance_wallet,  }

    return Container(

      padding: const EdgeInsets.all(20),              Colors.blue,

      decoration: BoxDecoration(

        color: Colors.white,            ),  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {

        borderRadius: BorderRadius.circular(16),

        boxShadow: [          ),    return Column(

          BoxShadow(

            color: Colors.black.withOpacity(0.05),          const SizedBox(width: 12),      children: [

            blurRadius: 10,

            offset: const Offset(0, 2),          Expanded(        Icon(icon, color: color, size: 32),

          ),

        ],            child: _buildStatCard(        const SizedBox(height: 8),

      ),

      child: Column(              'Expenses',        Text(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [              '$expenseCount',          value,

          const Text(

            'Recent Expenses',              Icons.receipt_long,          style: const TextStyle(

            style: TextStyle(

              fontSize: 18,              Colors.green,            fontSize: 20,

              fontWeight: FontWeight.bold,

            ),            ),            fontWeight: FontWeight.bold,

          ),

          const SizedBox(height: 16),          ),          ),

          if (recentExpenses.isEmpty)

            const Text('No recent expenses')          const SizedBox(width: 12),        ),

          else

            ...recentExpenses.map((expense) => _buildRecentExpenseItem(expense, provider)).toList(),          Expanded(        Text(

          if (recentExpenses.length >= 5) ...[

            const SizedBox(height: 12),            child: _buildStatCard(          title,

            Center(

              child: TextButton(              'Average',          style: TextStyle(

                onPressed: () {

                  _tabController.animateTo(1);              '\$${averageAmount.toStringAsFixed(2)}',            fontSize: 12,

                },

                child: const Text('View All Expenses'),              Icons.trending_up,            color: Colors.grey[600],

              ),

            ),              Colors.orange,          ),

          ],

        ],            ),          textAlign: TextAlign.center,

      ),

    );          ),        ),

  }

        ],      ],

  Widget _buildRecentExpenseItem(Expense expense, ExpenseAnalyticsProvider provider) {

    final category = provider.getCategoryById(expense.categoryId);      ),    );

    

    return Padding(    );  }

      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(  }

        children: [

          Container(  Widget _buildCategoryChart(ExpenseProvider provider) {

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(  Widget _buildStatCard(String title, String value, IconData icon, Color color) {    final categoryData = provider.expensesByCategory;

              color: (category?.color ?? Colors.grey).withOpacity(0.1),

              borderRadius: BorderRadius.circular(8),    return Container(    

            ),

            child: Icon(      padding: const EdgeInsets.all(16),    if (categoryData.isEmpty) {

              category?.icon ?? Icons.shopping_bag,

              color: category?.color ?? Colors.grey,      decoration: BoxDecoration(      return Card(

              size: 20,

            ),        color: Colors.white,        child: Container(

          ),

          const SizedBox(width: 12),        borderRadius: BorderRadius.circular(12),          height: 300,

          Expanded(

            child: Column(        boxShadow: [          child: const Center(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [          BoxShadow(            child: Text('No data available'),

                Text(

                  expense.title,            color: Colors.black.withOpacity(0.05),          ),

                  style: const TextStyle(

                    fontWeight: FontWeight.w500,            blurRadius: 10,        ),

                  ),

                ),            offset: const Offset(0, 2),      );

                Text(

                  DateFormat('MMM dd, yyyy').format(expense.date),          ),    }

                  style: TextStyle(

                    color: Colors.grey[600],        ],

                    fontSize: 12,

                  ),      ),    return Card(

                ),

              ],      child: Column(      child: Padding(

            ),

          ),        crossAxisAlignment: CrossAxisAlignment.start,        padding: const EdgeInsets.all(20),

          Text(

            '\$${expense.amount.toStringAsFixed(2)}',        children: [        child: Column(

            style: const TextStyle(

              fontWeight: FontWeight.bold,          Row(          crossAxisAlignment: CrossAxisAlignment.start,

              fontSize: 16,

            ),            mainAxisAlignment: MainAxisAlignment.spaceBetween,          children: [

          ),

        ],            children: [            const Text(

      ),

    );              Icon(icon, color: color, size: 24),              'Spending by Category',

  }

              Container(              style: TextStyle(

  Widget _buildExpenseFilters(ExpenseAnalyticsProvider provider) {

    return Container(                padding: const EdgeInsets.all(4),                fontSize: 18,

      padding: const EdgeInsets.all(16),

      child: TextField(                decoration: BoxDecoration(                fontWeight: FontWeight.bold,

        onChanged: (value) => provider.setSearchQuery(value),

        decoration: InputDecoration(                  color: color.withOpacity(0.1),              ),

          hintText: 'Search expenses...',

          prefixIcon: const Icon(Icons.search),                  borderRadius: BorderRadius.circular(4),            ),

          border: OutlineInputBorder(

            borderRadius: BorderRadius.circular(12),                ),            const SizedBox(height: 20),

            borderSide: BorderSide.none,

          ),                child: Icon(icon, color: color, size: 16),            SizedBox(

          filled: true,

          fillColor: Colors.white,              ),              height: 300,

        ),

      ),            ],              child: PieChart(

    );

  }          ),                PieChartData(



  Widget _buildExpenseItem(Expense expense, ExpenseAnalyticsProvider provider) {          const SizedBox(height: 12),                  sections: _createPieChartSections(categoryData),

    final category = provider.getCategoryById(expense.categoryId);

              Text(                  sectionsSpace: 2,

    return Container(

      margin: const EdgeInsets.only(bottom: 12),            value,                  centerSpaceRadius: 60,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(            style: const TextStyle(                  borderData: FlBorderData(show: false),

        color: Colors.white,

        borderRadius: BorderRadius.circular(12),              fontSize: 18,                ),

        boxShadow: [

          BoxShadow(              fontWeight: FontWeight.bold,              ),

            color: Colors.black.withOpacity(0.05),

            blurRadius: 5,            ),            ),

            offset: const Offset(0, 2),

          ),          ),            const SizedBox(height: 20),

        ],

      ),          const SizedBox(height: 4),            _buildCategoryLegend(categoryData),

      child: Row(

        children: [          Text(          ],

          Container(

            padding: const EdgeInsets.all(12),            title,        ),

            decoration: BoxDecoration(

              color: (category?.color ?? Colors.grey).withOpacity(0.1),            style: TextStyle(      ),

              borderRadius: BorderRadius.circular(12),

            ),              fontSize: 12,    );

            child: Icon(

              category?.icon ?? Icons.shopping_bag,              color: Colors.grey[600],  }

              color: category?.color ?? Colors.grey,

              size: 24,            ),

            ),

          ),          ),  List<PieChartSectionData> _createPieChartSections(Map<String, double> data) {

          const SizedBox(width: 16),

          Expanded(        ],    final total = data.values.fold(0.0, (sum, value) => sum + value);

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,      ),    final colors = [

              children: [

                Text(    );      Colors.blue,

                  expense.title,

                  style: const TextStyle(  }      Colors.red,

                    fontWeight: FontWeight.w600,

                    fontSize: 16,      Colors.green,

                  ),

                ),  Widget _buildTabBar() {      Colors.orange,

                const SizedBox(height: 4),

                Text(    return Container(      Colors.purple,

                  expense.description,

                  style: TextStyle(      margin: const EdgeInsets.all(16),      Colors.teal,

                    color: Colors.grey[600],

                    fontSize: 14,      child: TabBar(      Colors.pink,

                  ),

                  maxLines: 2,        controller: _tabController,      Colors.indigo,

                  overflow: TextOverflow.ellipsis,

                ),        labelColor: Colors.white,    ];

                const SizedBox(height: 8),

                Text(        unselectedLabelColor: Colors.black54,

                  DateFormat('MMM dd, yyyy').format(expense.date),

                  style: TextStyle(        indicator: BoxDecoration(    return data.entries.map((entry) {

                    color: Colors.grey[500],

                    fontSize: 12,          color: Colors.black,      final index = data.keys.toList().indexOf(entry.key);

                  ),

                ),          borderRadius: BorderRadius.circular(25),      final percentage = (entry.value / total * 100);

              ],

            ),        ),      

          ),

          Column(        tabs: const [      return PieChartSectionData(

            crossAxisAlignment: CrossAxisAlignment.end,

            children: [          Tab(text: 'Overview'),        value: entry.value,

              Text(

                '\$${expense.amount.toStringAsFixed(2)}',          Tab(text: 'Analytics'),        title: '${percentage.toStringAsFixed(1)}%',

                style: const TextStyle(

                  fontWeight: FontWeight.bold,          Tab(text: 'Categories'),        color: colors[index % colors.length],

                  fontSize: 18,

                ),          Tab(text: 'Expenses'),        radius: 80,

              ),

              const SizedBox(height: 8),        ],        titleStyle: const TextStyle(

              Row(

                mainAxisSize: MainAxisSize.min,      ),          fontSize: 12,

                children: [

                  IconButton(    );          fontWeight: FontWeight.bold,

                    onPressed: () => _editExpense(expense),

                    icon: const Icon(Icons.edit, size: 18),  }          color: Colors.white,

                    style: IconButton.styleFrom(

                      minimumSize: const Size(32, 32),        ),

                    ),

                  ),  Widget _buildOverviewTab(ExpenseAnalyticsProvider provider) {      );

                  IconButton(

                    onPressed: () => _deleteExpense(expense, provider),    final monthlyData = provider.getMonthlyData(selectedMonth);    }).toList();

                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),

                    style: IconButton.styleFrom(      }

                      minimumSize: const Size(32, 32),

                    ),    return SingleChildScrollView(

                  ),

                ],      padding: const EdgeInsets.all(16),  Widget _buildCategoryLegend(Map<String, double> data) {

              ),

            ],      child: Column(    final colors = [

          ),

        ],        crossAxisAlignment: CrossAxisAlignment.start,      Colors.blue,

      ),

    );        children: [      Colors.red,

  }

          ExpenseStatsCard(monthlyData: monthlyData),      Colors.green,

  Widget _buildEmptyState() {

    return Center(          const SizedBox(height: 20),      Colors.orange,

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,          ExpenseTrendCard(      Colors.purple,

        children: [

          Icon(            provider: provider,      Colors.teal,

            Icons.receipt_long_outlined,

            size: 64,            selectedMonth: selectedMonth,      Colors.pink,

            color: Colors.grey[400],

          ),          ),      Colors.indigo,

          const SizedBox(height: 16),

          Text(          const SizedBox(height: 20),    ];

            'No expenses found',

            style: TextStyle(          _buildRecentExpenses(provider),

              fontSize: 18,

              color: Colors.grey[600],        ],    return Column(

              fontWeight: FontWeight.w500,

            ),      ),      children: data.entries.map((entry) {

          ),

          const SizedBox(height: 24),    );        final index = data.keys.toList().indexOf(entry.key);

          ElevatedButton.icon(

            onPressed: () => _navigateToAddExpense(context),  }        return Padding(

            icon: const Icon(Icons.add),

            label: const Text('Add Expense'),          padding: const EdgeInsets.symmetric(vertical: 4),

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.black,  Widget _buildAnalyticsTab(ExpenseAnalyticsProvider provider) {          child: Row(

              foregroundColor: Colors.white,

            ),    return SingleChildScrollView(            children: [

          ),

        ],      padding: const EdgeInsets.all(16),              Container(

      ),

    );      child: Column(                width: 16,

  }

        crossAxisAlignment: CrossAxisAlignment.start,                height: 16,

  void _navigateToAddExpense(BuildContext context) {

    Navigator.push(        children: [                decoration: BoxDecoration(

      context,

      MaterialPageRoute(          const Text(                  color: colors[index % colors.length],

        builder: (context) => const AddEditExpenseScreen(),

      ),            'Monthly Trends',                  shape: BoxShape.circle,

    ).then((_) {

      context.read<ExpenseAnalyticsProvider>().loadData();            style: TextStyle(                ),

    });

  }              fontSize: 20,              ),



  void _editExpense(Expense expense) {              fontWeight: FontWeight.bold,              const SizedBox(width: 8),

    Navigator.push(

      context,            ),              Expanded(

      MaterialPageRoute(

        builder: (context) => AddEditExpenseScreen(expense: expense),          ),                child: Text(

      ),

    ).then((_) {          const SizedBox(height: 16),                  entry.key,

      context.read<ExpenseAnalyticsProvider>().loadData();

    });          ExpenseMonthlyChart(yearlyTrends: provider.yearlyTrends),                  style: const TextStyle(fontSize: 14),

  }

          const SizedBox(height: 24),                ),

  void _deleteExpense(Expense expense, ExpenseAnalyticsProvider provider) {

    showDialog(          _buildSpendingPatterns(provider),              ),

      context: context,

      builder: (context) => AlertDialog(        ],              Text(

        title: const Text('Delete Expense'),

        content: Text('Are you sure you want to delete "${expense.title}"?'),      ),                NumberFormat.currency(symbol: '\$').format(entry.value),

        actions: [

          TextButton(    );                style: const TextStyle(

            onPressed: () => Navigator.pop(context),

            child: const Text('Cancel'),  }                  fontSize: 14,

          ),

          TextButton(                  fontWeight: FontWeight.w600,

            onPressed: () {

              Navigator.pop(context);  Widget _buildCategoriesTab(ExpenseAnalyticsProvider provider) {                ),

              provider.deleteExpense(expense.id!);

            },    return SingleChildScrollView(              ),

            child: const Text('Delete', style: TextStyle(color: Colors.red)),

          ),      padding: const EdgeInsets.all(16),            ],

        ],

      ),      child: Column(          ),

    );

  }        crossAxisAlignment: CrossAxisAlignment.start,        );

}
        children: [      }).toList(),

          const Text(    );

            'Category Breakdown',  }

            style: TextStyle(

              fontSize: 20,  Widget _buildMonthlyTrendChart() {

              fontWeight: FontWeight.bold,    return Card(

            ),      child: Padding(

          ),        padding: const EdgeInsets.all(20),

          const SizedBox(height: 16),        child: Column(

          ExpenseCategoryChart(categorySpending: provider.getSpendingByCategory()),          crossAxisAlignment: CrossAxisAlignment.start,

          const SizedBox(height: 24),          children: [

          _buildCategoryList(provider),            const Text(

        ],              'Monthly Spending Trend',

      ),              style: TextStyle(

    );                fontSize: 18,

  }                fontWeight: FontWeight.bold,

              ),

  Widget _buildExpensesTab(ExpenseAnalyticsProvider provider) {            ),

    final expenses = provider.filteredExpenses;            const SizedBox(height: 20),

                FutureBuilder<Map<String, double>>(

    return Column(              future: context.read<ExpenseProvider>().getMonthlyExpenses(_selectedYear),

      children: [              builder: (context, snapshot) {

        _buildExpenseFilters(provider),                if (snapshot.connectionState == ConnectionState.waiting) {

        Expanded(                  return const SizedBox(

          child: expenses.isEmpty                    height: 200,

              ? _buildEmptyState()                    child: Center(child: CircularProgressIndicator()),

              : ListView.builder(                  );

                  padding: const EdgeInsets.all(16),                }

                  itemCount: expenses.length,

                  itemBuilder: (context, index) {                if (!snapshot.hasData || snapshot.data!.isEmpty) {

                    return _buildExpenseItem(expenses[index], provider);                  return const SizedBox(

                  },                    height: 200,

                ),                    child: Center(child: Text('No data available')),

        ),                  );

      ],                }

    );

  }                return SizedBox(

                  height: 200,

  Widget _buildSpendingPatterns(ExpenseAnalyticsProvider provider) {                  child: LineChart(

    final comparison = provider.getSpendingComparison(                    LineChartData(

      DateTime(selectedMonth.year, selectedMonth.month, 1),                      gridData: const FlGridData(show: true),

      DateTime(selectedMonth.year, selectedMonth.month + 1, 0),                      titlesData: FlTitlesData(

    );                        leftTitles: AxisTitles(

                          sideTitles: SideTitles(

    return Container(                            showTitles: true,

      padding: const EdgeInsets.all(20),                            reservedSize: 40,

      decoration: BoxDecoration(                            getTitlesWidget: (value, meta) {

        color: Colors.white,                              return Text(

        borderRadius: BorderRadius.circular(16),                                '\$${(value / 1000).toStringAsFixed(0)}K',

        boxShadow: [                                style: const TextStyle(fontSize: 10),

          BoxShadow(                              );

            color: Colors.black.withOpacity(0.05),                            },

            blurRadius: 10,                          ),

            offset: const Offset(0, 2),                        ),

          ),                        bottomTitles: AxisTitles(

        ],                          sideTitles: SideTitles(

      ),                            showTitles: true,

      child: Column(                            getTitlesWidget: (value, meta) {

        crossAxisAlignment: CrossAxisAlignment.start,                              const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

        children: [                              if (value.toInt() < months.length) {

          Row(                                return Text(months[value.toInt()]);

            mainAxisAlignment: MainAxisAlignment.spaceBetween,                              }

            children: [                              return const Text('');

              const Text(                            },

                'vs Previous Month',                          ),

                style: TextStyle(                        ),

                  fontSize: 16,                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  fontWeight: FontWeight.w500,                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                ),                      ),

              ),                      borderData: FlBorderData(show: true),

              Icon(                      lineBarsData: [

                comparison['isIncrease'] ? Icons.trending_up : Icons.trending_down,                        LineChartBarData(

                color: comparison['isIncrease'] ? Colors.red : Colors.green,                          spots: _createLineChartSpots(snapshot.data!),

              ),                          isCurved: true,

            ],                          color: Theme.of(context).primaryColor,

          ),                          barWidth: 3,

          const SizedBox(height: 16),                          dotData: const FlDotData(show: true),

          Row(                        ),

            mainAxisAlignment: MainAxisAlignment.spaceBetween,                      ],

            children: [                    ),

              Column(                  ),

                crossAxisAlignment: CrossAxisAlignment.start,                );

                children: [              },

                  Text(            ),

                    'Current',          ],

                    style: TextStyle(        ),

                      color: Colors.grey[600],      ),

                      fontSize: 12,    );

                    ),  }

                  ),

                  Text(  List<FlSpot> _createLineChartSpots(Map<String, double> monthlyData) {

                    '\$${comparison['currentTotal'].toStringAsFixed(2)}',    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

                    style: const TextStyle(    

                      fontSize: 18,    return months.asMap().entries.map((entry) {

                      fontWeight: FontWeight.bold,      final monthName = entry.value;

                    ),      final amount = monthlyData[monthName] ?? 0.0;

                  ),      return FlSpot(entry.key.toDouble(), amount);

                ],    }).toList();

              ),  }

              Column(

                crossAxisAlignment: CrossAxisAlignment.end,  Widget _buildPredictionsCard() {

                children: [    return Card(

                  Text(      child: Padding(

                    'Change',        padding: const EdgeInsets.all(20),

                    style: TextStyle(        child: Column(

                      color: Colors.grey[600],          crossAxisAlignment: CrossAxisAlignment.start,

                      fontSize: 12,          children: [

                    ),            const Text(

                  ),              'AI Predictions',

                  Text(              style: TextStyle(

                    '${comparison['changePercentage'] >= 0 ? '+' : ''}${comparison['changePercentage'].toStringAsFixed(1)}%',                fontSize: 18,

                    style: TextStyle(                fontWeight: FontWeight.bold,

                      fontSize: 18,              ),

                      fontWeight: FontWeight.bold,            ),

                      color: comparison['isIncrease'] ? Colors.red : Colors.green,            const SizedBox(height: 16),

                    ),            FutureBuilder<Map<String, dynamic>>(

                  ),              future: context.read<ExpenseProvider>().getExpensePredictions(),

                ],              builder: (context, snapshot) {

              ),                if (snapshot.connectionState == ConnectionState.waiting) {

            ],                  return const Center(child: CircularProgressIndicator());

          ),                }

        ],

      ),                if (!snapshot.hasData || snapshot.data!.isEmpty) {

    );                  return const Text('No predictions available');

  }                }



  Widget _buildRecentExpenses(ExpenseAnalyticsProvider provider) {                final predictions = snapshot.data!;

    final recentExpenses = provider.recentExpenses.take(5).toList();                final projectedTotal = predictions['projectedMonthTotal'] ?? 0.0;

                final dailyAverage = predictions['dailyAverage'] ?? 0.0;

    return Container(

      padding: const EdgeInsets.all(20),                return Column(

      decoration: BoxDecoration(                  children: [

        color: Colors.white,                    _buildPredictionItem(

        borderRadius: BorderRadius.circular(16),                      'Projected Month Total',

        boxShadow: [                      NumberFormat.currency(symbol: '\$').format(projectedTotal),

          BoxShadow(                      Icons.trending_up,

            color: Colors.black.withOpacity(0.05),                      Colors.blue,

            blurRadius: 10,                    ),

            offset: const Offset(0, 2),                    const SizedBox(height: 12),

          ),                    _buildPredictionItem(

        ],                      'Daily Average',

      ),                      NumberFormat.currency(symbol: '\$').format(dailyAverage),

      child: Column(                      Icons.today,

        crossAxisAlignment: CrossAxisAlignment.start,                      Colors.green,

        children: [                    ),

          const Text(                  ],

            'Recent Expenses',                );

            style: TextStyle(              },

              fontSize: 18,            ),

              fontWeight: FontWeight.bold,          ],

            ),        ),

          ),      ),

          const SizedBox(height: 16),    );

          ...recentExpenses.map((expense) => _buildRecentExpenseItem(expense, provider)).toList(),  }

          if (recentExpenses.length >= 5) ...[

            const SizedBox(height: 12),  Widget _buildPredictionItem(String title, String value, IconData icon, Color color) {

            Center(    return Row(

              child: TextButton(      children: [

                onPressed: () {        Icon(icon, color: color, size: 24),

                  _tabController.animateTo(3);        const SizedBox(width: 12),

                },        Expanded(

                child: const Text('View All Expenses'),          child: Column(

              ),            crossAxisAlignment: CrossAxisAlignment.start,

            ),            children: [

          ],              Text(

        ],                title,

      ),                style: TextStyle(

    );                  fontSize: 14,

  }                  color: Colors.grey[600],

                ),

  Widget _buildRecentExpenseItem(Expense expense, ExpenseAnalyticsProvider provider) {              ),

    final category = provider.getCategoryById(expense.categoryId);              Text(

                    value,

    return Padding(                style: const TextStyle(

      padding: const EdgeInsets.symmetric(vertical: 8),                  fontSize: 18,

      child: Row(                  fontWeight: FontWeight.bold,

        children: [                ),

          Container(              ),

            padding: const EdgeInsets.all(8),            ],

            decoration: BoxDecoration(          ),

              color: (category?.color ?? Colors.grey).withOpacity(0.1),        ),

              borderRadius: BorderRadius.circular(8),      ],

            ),    );

            child: Icon(  }

              category?.icon ?? Icons.shopping_bag,}
              color: category?.color ?? Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ExpenseAnalyticsProvider provider) {
    final categorySpending = provider.getSpendingByCategory();
    final totalSpent = categorySpending.values.fold(0.0, (sum, amount) => sum + amount);

    return Container(
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
            'Category Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categorySpending.entries.map((entry) {
            final percentage = totalSpent > 0 ? (entry.value / totalSpent) * 100 : 0;
            final category = provider.categories.firstWhere(
              (cat) => cat.name == entry.key,
              orElse: () => ExpenseCategory(
                name: entry.key,
                description: '',
                icon: Icons.shopping_bag,
                color: Colors.grey,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            return _buildCategoryItem(category, entry.value, percentage);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(ExpenseCategory category, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(category.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseFilters(ExpenseAnalyticsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense, ExpenseAnalyticsProvider provider) {
    final category = provider.getCategoryById(expense.categoryId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (category?.color ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category?.icon ?? Icons.shopping_bag,
              color: category?.color ?? Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.category,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category?.name ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editExpense(expense),
                    icon: const Icon(Icons.edit, size: 18),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteExpense(expense, provider),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                    ),
                  ),
                ],
              ),
            ],
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
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddExpense(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation and Dialog Methods
  
  void _navigateToAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditExpenseScreen(),
      ),
    ).then((_) {
      context.read<ExpenseAnalyticsProvider>().loadData();
    });
  }

  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    ).then((_) {
      context.read<ExpenseAnalyticsProvider>().loadData();
    });
  }

  void _deleteExpense(Expense expense, ExpenseAnalyticsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteExpense(expense.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: const Text('Filter functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}