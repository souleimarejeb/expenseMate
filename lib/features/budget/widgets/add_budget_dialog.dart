import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:expensemate/core/repositories/budget_repository.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddBudgetDialog extends StatefulWidget {
  final Function(Budget)? onBudgetAdded; // Make it optional since we're handling it internally

  const AddBudgetDialog({Key? key, this.onBudgetAdded}) : super(key: key);

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  final _categoryController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  bool _isLoading = false; // Add loading state

  final BudgetRepository _budgetRepository = BudgetRepository(); // Add repository instance

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

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      // Create budget using repository
      final budgetId = await _budgetRepository.createBudget(
        limitAmount: double.parse(_limitController.text),
        month: _selectedMonth,
        createdAt: now,
        updatedAt: now,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
      );

      // Create the budget object for callback
      final newBudget = Budget(
        id: budgetId, // Convert the returned ID to string
        limitAmount: double.parse(_limitController.text),
        spentAmount: 0, // Start with 0 spent
        status: BudgetStatus.ok,
        createdAt: now,
        updatedAt: now,
        month: _selectedMonth,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
      );

      // Call the callback if provided
      widget.onBudgetAdded?.call(newBudget);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create budget: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Budget",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
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
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedMonth,
                decoration: const InputDecoration(
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
                onChanged: _isLoading ? null : (value) { // Disable when loading
                  setState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
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
                onChanged: _isLoading ? null : (value) { // Disable when loading
                  _categoryController.text = value!;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(), // Disable when loading
                    child: Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitBudget, // Disable when loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("CREATE BUDGET"),
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