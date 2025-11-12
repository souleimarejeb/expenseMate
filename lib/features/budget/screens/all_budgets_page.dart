import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/core/repositories/budget_repository.dart'; // Add this import
import 'package:expensemate/features/budget/pages/budget_details_page.dart';
import 'package:expensemate/features/budget/widgets/budget_list_item.dart';
import 'package:expensemate/features/budget/widgets/add_budget_dialog.dart'; // Add this import
import 'package:flutter/material.dart';

class AllBudgetsPage extends StatefulWidget {
  const AllBudgetsPage({Key? key}) : super(key: key);

  @override
  State<AllBudgetsPage> createState() => _AllBudgetsPageState();
}

class _AllBudgetsPageState extends State<AllBudgetsPage> {
  List<Budget> budgets = [];
  final BudgetRepository _budgetRepository = BudgetRepository(); // Add repository
  bool _isLoading = true; // Add loading state
  String _errorMessage = ''; // Add error handling

  @override
  void initState() {
    super.initState();
    _loadBudgets(); // Load budgets when the page initializes
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<Budget> loadedBudgets = await _budgetRepository.getAllBudgets();
      setState(() {
        budgets = loadedBudgets;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load budgets: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetAdded: _handleBudgetAdded,
      ),
    );
  }

  void _handleBudgetAdded(Budget newBudget) {
    setState(() {
      budgets.add(newBudget);
    });
    // Optionally, you can reload from database to ensure consistency
    // _loadBudgets();
  }

  void _refreshBudgets() {
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Budget Manager', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshBudgets,
            tooltip: 'Refresh budgets',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBudgetDialog,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Budget",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading budgets...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading budgets',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBudgets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No budgets yet",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to create your first budget",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBudgets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          return BudgetListItem(budget: budget);
        },
      ),
    );
  }
}