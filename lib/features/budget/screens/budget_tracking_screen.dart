import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/models/bugets/budget.dart';
import '../../../core/models/bugets/budget_status.dart';
import '../providers/budget_tracking_provider.dart';
import '../widgets/monthly_spending_chart.dart';
import '../widgets/budget_comparison_chart.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/quick_add_expense_sheet.dart';
import '../widgets/expense_filter_widget.dart';
import 'category_budget_detail_screen.dart';

class BudgetTrackingScreen extends StatefulWidget {
  const BudgetTrackingScreen({Key? key}) : super(key: key);

  @override
  State<BudgetTrackingScreen> createState() => _BudgetTrackingScreenState();
}

class _BudgetTrackingScreenState extends State<BudgetTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedMonth = DateTime.now();
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetTrackingProvider>().initialize();
      context.read<BudgetTrackingProvider>().loadMonthlyData(selectedMonth);
    });
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
      appBar: _buildAppBar(),
      body: Consumer<BudgetTrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          return Column(
            children: [
              _buildMonthSelector(),
              _buildBudgetOverview(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider),
                    _buildAnalyticsTab(provider),
                    _buildComparisonTab(provider),
                    _buildExpensesTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddBudgetDialog(context),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            heroTag: "add_budget",
            child: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => _showQuickAddExpense(context),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Budget Tracking',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.add_chart, color: Colors.black87),
          onPressed: () => _showAddBudgetDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black87),
          onPressed: () => _showFilterSheet(context),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.black,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Analytics'),
          Tab(text: 'Compare'),
          Tab(text: 'Expenses'),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverview(BudgetTrackingProvider provider) {
    final monthlyData = provider.getMonthlyData(selectedMonth);
    final totalBudget = monthlyData?.totalBudget ?? 0.0;
    final totalSpent = monthlyData?.totalSpent ?? 0.0;
    final remaining = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    Color statusColor;
    String statusText;
    if (percentage > 1.0) {
      statusColor = Colors.red;
      statusText = 'Over Budget';
    } else if (percentage > 0.8) {
      statusColor = Colors.orange;
      statusText = 'Near Limit';
    } else {
      statusColor = Colors.green;
      statusText = 'On Track';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Budget',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(totalBudget)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(totalSpent)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(remaining)}',
                      style: TextStyle(
                        color: remaining >= 0 ? Colors.green[300] : Colors.red[300],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage > 1.0 ? 1.0 : percentage,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toInt()}% of budget used',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BudgetTrackingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          MonthlySpendingChart(
            monthlyData: provider.getMonthlyData(selectedMonth),
          ),
          const SizedBox(height: 24),
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          CategoryBreakdownCard(
            monthlyData: provider.getMonthlyData(selectedMonth),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BudgetTrackingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpendingTrendsChart(provider),
          const SizedBox(height: 24),
          const Text(
            'Category Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryPerformanceCards(provider),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(BudgetTrackingProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Month-to-Month Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          BudgetComparisonChart(
            currentMonth: selectedMonth,
            provider: provider,
          ),
          const SizedBox(height: 24),
          const Text(
            'Year-over-Year Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildYearOverYearComparison(provider),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(BudgetTrackingProvider provider) {
    final expenses = provider.getExpensesForMonth(selectedMonth);

    return Column(
      children: [
        ExpenseFilterWidget(
          selectedCategory: selectedCategory,
          categories: provider.categories,
          onCategoryChanged: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              if (selectedCategory != 'All' && expense.categoryId != selectedCategory) {
                return const SizedBox.shrink();
              }
              return _buildExpenseCard(expense, provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense, BudgetTrackingProvider provider) {
    final category = provider.getCategoryById(expense.categoryId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category?.color.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category?.icon ?? Icons.category,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(expense.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(expense.amount)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendsChart(BudgetTrackingProvider provider) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Spending Trends Chart\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceCards(BudgetTrackingProvider provider) {
    return Column(
      children: provider.categories.map((category) {
        final monthlyData = provider.getMonthlyData(selectedMonth);
        final categorySpending = monthlyData?.categorySpending[category.id] ?? 0.0;
        final categoryBudget = monthlyData?.categoryBudgets[category.id] ?? 0.0;
        final percentage = categoryBudget > 0 ? (categorySpending / categoryBudget) : 0.0;

        return GestureDetector(
          onTap: () {
            _navigateToCategoryDetail(context, category, monthlyData);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(category.icon, color: category.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(categorySpending)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage > 1.0 ? 1.0 : percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 1.0 ? Colors.red : category.color,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: \$${NumberFormat('#,##0.00').format(categoryBudget)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: percentage > 1.0 ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ========== ADD BUDGET DIALOG METHODS ==========

  void _showAddBudgetDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _limitController = TextEditingController();
    String? _selectedCategory;
    int _selectedMonth = DateTime.now().month;
    int _selectedYear = DateTime.now().year;
    bool _isSubmitting = false;

    final provider = context.read<BudgetTrackingProvider>();
    final categories = provider.categories;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Colors.black87, size: 24),
                              const SizedBox(width: 12),
                              const Text(
                                "Create New Budget",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Set a monthly spending limit for a category",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category Dropdown
                          _buildCategoryDropdown(
                            categories: categories,
                            selectedCategory: _selectedCategory,
                            onChanged: (value) => setState(() => _selectedCategory = value),
                          ),
                          const SizedBox(height: 20),

                          // Limit Amount Field
                          _buildAmountField(
                            controller: _limitController,
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 20),

                          // Month and Year Selection
                          _buildMonthYearSelection(
                            selectedMonth: _selectedMonth,
                            selectedYear: _selectedYear,
                            onMonthChanged: (value) => setState(() => _selectedMonth = value),
                            onYearChanged: (value) => setState(() => _selectedYear = value),
                          ),
                          const SizedBox(height: 30),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 150),
                                  scale: _isSubmitting ? 0.95 : 1.0,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : () => _createBudget(
                                      context,
                                      setState,
                                      _formKey,
                                      _selectedCategory,
                                      _limitController,
                                      _selectedMonth,
                                      _selectedYear,
                                      provider,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Text(
                                      'Create Budget',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryDropdown({
    required List<ExpenseCategory> categories,
    required String? selectedCategory,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              isDense: true,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(
                  "Select a category",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ...categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 12),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
            ],
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please select a category";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Budget Limit",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
            hintText: "0.00",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a budget amount";
            }
            final amount = double.tryParse(value);
            if (amount == null) {
              return "Please enter a valid number";
            }
            if (amount <= 0) {
              return "Amount must be greater than 0";
            }
            return null;
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMonthYearSelection({
    required int selectedMonth,
    required int selectedYear,
    required Function(int) onMonthChanged,
    required Function(int) onYearChanged,
  }) {
    final months = [
      {'value': 1, 'label': 'January'},
      {'value': 2, 'label': 'February'},
      {'value': 3, 'label': 'March'},
      {'value': 4, 'label': 'April'},
      {'value': 5, 'label': 'May'},
      {'value': 6, 'label': 'June'},
      {'value': 7, 'label': 'July'},
      {'value': 8, 'label': 'August'},
      {'value': 9, 'label': 'September'},
      {'value': 10, 'label': 'October'},
      {'value': 11, 'label': 'November'},
      {'value': 12, 'label': 'December'},
    ];

    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear + index);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Month",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  items: months.map((month) {
                    return DropdownMenuItem(
                      value: month['value'] as int,
                      child: Text(month['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) => onMonthChanged(value!),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Year",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedYear,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (value) => onYearChanged(value!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _createBudget(
      BuildContext context,
      Function(void Function()) setState,
      GlobalKey<FormState> formKey,
      String? selectedCategory,
      TextEditingController limitController,
      int selectedMonth,
      int selectedYear,
      BudgetTrackingProvider provider,
      ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    bool isSubmitting = true;
    setState(() {
      isSubmitting = true;
    });

    try {
      // Create new budget
      final newBudget = Budget(
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
        limitAmount: double.parse(limitController.text),
        spentAmount: 0.0,
        status: BudgetStatus.ok,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        month: selectedMonth,
        category: selectedCategory,
      );

      // TODO: Add budget creation logic to provider
      // await provider.addBudget(newBudget);

      // For now, just show success and close
      if (context.mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create budget: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _navigateToCategoryDetail(BuildContext context, ExpenseCategory category, MonthlyBudgetData? monthlyData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryBudgetDetailScreen(
          category: category,
          monthlyData: monthlyData,
          selectedMonth: selectedMonth,
        ),
      ),
    );
  }

  Widget _buildYearOverYearComparison(BudgetTrackingProvider provider) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Year-over-Year Comparison\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  void _changeMonth(int increment) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + increment,
        1,
      );
    });
    context.read<BudgetTrackingProvider>().loadMonthlyData(selectedMonth);
  }

  void _showQuickAddExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddExpenseSheet(
        onExpenseAdded: () {
          context.read<BudgetTrackingProvider>().loadMonthlyData(selectedMonth);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter options coming soon...'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                // Implement export functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
          ],
        ),
      ),
    );
  }
}