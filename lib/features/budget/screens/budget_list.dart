// budget_list.dart
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllBudgetsPage extends StatefulWidget {
  AllBudgetsPage({Key? key}) : super(key: key);

  @override
  State<AllBudgetsPage> createState() => _AllBudgetsPageState();
}

class _AllBudgetsPageState extends State<AllBudgetsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Budget> budgets = [
    Budget(
      limitAmount: 500,
      spentAmount: 200,
      status: BudgetStatus.ok,
      createdAt: DateTime(2025, 9, 1),
      updatedAt: DateTime(2025, 9, 5),
      month: 9,
      category: "Food & Dining",
    ),
    Budget(
      limitAmount: 300,
      spentAmount: 290,
      status: BudgetStatus.nearLimit,
      createdAt: DateTime(2025, 9, 2),
      updatedAt: DateTime(2025, 9, 10),
      month: 9,
      category: "Shopping",
    ),
    Budget(
      limitAmount: 100,
      spentAmount: 120,
      status: BudgetStatus.exceeded,
      createdAt: DateTime(2025, 9, 3),
      updatedAt: DateTime(2025, 9, 8),
      month: 9,
      category: "Entertainment",
    ),
    Budget(
      limitAmount: 400,
      spentAmount: 150,
      status: BudgetStatus.ok,
      createdAt: DateTime(2025, 9, 1),
      updatedAt: DateTime(2025, 9, 5),
      month: 9,
      category: "Transportation",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addBudget(Budget newBudget) {
    setState(() {
      budgets.add(newBudget);
    });
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddBudgetDialog(onBudgetAdded: _addBudget);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Budget Manager', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Budgets'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddBudgetDialog,
              backgroundColor: Colors.black,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Budget",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Budgets List
          _buildBudgetsTab(),
          // Tab 2: Statistics
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab() {
    return budgets.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  "No budgets yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  "Tap the + button to create your first budget",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetListItem(budget: budget);
            },
          );
  }

  Widget _buildStatisticsTab() {
    // Calculate statistics
    final totalLimit = budgets.fold(0.0, (sum, budget) => sum + budget.limitAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
    final totalRemaining = totalLimit - totalSpent;
    final averageUsage = budgets.isNotEmpty 
        ? budgets.fold(0.0, (sum, budget) => sum + budget.percentageUsed) / budgets.length 
        : 0.0;

    // Category breakdown
    final categorySpending = <String, double>{};
    for (var budget in budgets) {
      final category = budget.category ?? 'Uncategorized';
      categorySpending[category] = (categorySpending[category] ?? 0) + budget.spentAmount;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCard(totalLimit, totalSpent, totalRemaining, averageUsage),
          
          SizedBox(height: 24),
          
          // Budget Status Distribution
          _buildStatusDistribution(),
          
          SizedBox(height: 24),
          
          // Spending by Category
          _buildCategorySpending(categorySpending, totalSpent),
          
          SizedBox(height: 24),
          
          // Monthly Progress
          _buildMonthlyProgress(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalLimit, double totalSpent, double totalRemaining, double averageUsage) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Financial Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Total Limit", "\$${totalLimit.toStringAsFixed(2)}", Icons.account_balance_wallet),
                _buildStatItem("Total Spent", "\$${totalSpent.toStringAsFixed(2)}", Icons.money_off),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Remaining", "\$${totalRemaining.toStringAsFixed(2)}", 
                    totalRemaining >= 0 ? Icons.trending_up : Icons.trending_down),
                _buildStatItem("Avg Usage", "${averageUsage.toStringAsFixed(1)}%", Icons.percent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution() {
    final statusCounts = {
      'On Track': budgets.where((b) => b.status == BudgetStatus.ok).length,
      'Near Limit': budgets.where((b) => b.status == BudgetStatus.nearLimit).length,
      'Exceeded': budgets.where((b) => b.status == BudgetStatus.exceeded).length,
    };

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Budget Status",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              final color = entry.key == 'On Track' ? Colors.green 
                : entry.key == 'Near Limit' ? Colors.orange 
                : Colors.red;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    Text(
                      "${entry.value} budgets",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpending(Map<String, double> categorySpending, double totalSpent) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spending by Category",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ...categorySpending.entries.map((entry) {
              final percentage = totalSpent > 0 ? (entry.value / totalSpent * 100) : 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "\$${entry.value.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    // Group budgets by month and calculate monthly totals
    final monthlyData = <int, Map<String, double>>{};
    for (var budget in budgets) {
      if (!monthlyData.containsKey(budget.month)) {
        monthlyData[budget.month] = {'limit': 0.0, 'spent': 0.0};
      }
      monthlyData[budget.month]!['limit'] = monthlyData[budget.month]!['limit']! + budget.limitAmount;
      monthlyData[budget.month]!['spent'] = monthlyData[budget.month]!['spent']! + budget.spentAmount;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ...monthlyData.entries.map((entry) {
              final month = entry.key;
              final limit = entry.value['limit']!;
              final spent = entry.value['spent']!;
              final percentage = limit > 0 ? (spent / limit * 100) : 0;
              
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime(2025, month)),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 100 ? Colors.red : 
                              percentage > 80 ? Colors.orange : Colors.green
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Spent: \$${spent.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          "Limit: \$${limit.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _BudgetListItem extends StatelessWidget {
  final Budget budget;

  const _BudgetListItem({required this.budget});

  @override
  Widget build(BuildContext context) {
    final progress = budget.spentAmount / budget.limitAmount;
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    String statusText = "On Track";

    if (budget.status == BudgetStatus.nearLimit) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = "Near Limit";
    } else if (budget.status == BudgetStatus.exceeded) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = "Exceeded";
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category ?? "Uncategorized",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Month: ${DateFormat('MMMM yyyy').format(DateTime(2025, budget.month))}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spent",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      "\$${budget.spentAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Limit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      "\$${budget.limitAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remaining",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      "\$${budget.remaining.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: budget.remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1.0 ? Colors.red : 
                progress > 0.8 ? Colors.orange : Colors.green,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${budget.percentageUsed.toStringAsFixed(1)}% used",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${(100 - budget.percentageUsed).toStringAsFixed(1)}% left",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddBudgetDialog extends StatefulWidget {
  final Function(Budget) onBudgetAdded;

  const AddBudgetDialog({required this.onBudgetAdded});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _categoryController = TextEditingController();
  int _selectedMonth = DateTime.now().month;

  final List<String> categories = [
    "Food & Dining",
    "Shopping",
    "Entertainment",
    "Transportation",
    "Utilities",
    "Healthcare",
    "Education",
    "Travel",
    "Other"
  ];

  @override
  void dispose() {
    _limitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _submitBudget() {
    if (_formKey.currentState!.validate()) {
      final newBudget = Budget(
        limitAmount: double.parse(_limitController.text),
        spentAmount: 0, // Start with 0 spent
        status: BudgetStatus.ok,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        month: _selectedMonth,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
      );

      widget.onBudgetAdded(newBudget);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New Budget",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _limitController,
                decoration: InputDecoration(
                  labelText: "Budget Limit",
                  hintText: "Enter amount",
                  prefixText: "\$",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget limit';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: InputDecoration(
                  labelText: "Month",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(DateFormat('MMMM').format(DateTime(2025, month))),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Category (Optional)",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  _categoryController.text = value!;
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("CREATE BUDGET"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}