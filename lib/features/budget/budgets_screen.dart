import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';
import 'package:flutter/material.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({Key? key}) : super(key: key);

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limitController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  String? _selectedCategory;

  final List<String> _months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Other',
  ];

 void _createBudget() {
    if (_formKey.currentState!.validate()) {
      final double limit = double.parse(_limitController.text);

      final newBudget = Budget(
        limitAmount: limit,
        spentAmount: 0.0,
        status: BudgetStatus.ok,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        month: _selectedMonth,
      );

      // TODO: Save to backend or local DB
      print('✅ New Budget Created: ${newBudget.toJson()}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget created successfully!')),
      );

      Navigator.pop(context, newBudget);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Budget', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          prefixIcon: const Icon(Icons.category, color: Colors.black),
                        ),
                        value: _selectedCategory,
                        items: _categories.map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.black)),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                        validator: (val) => val == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 20),

                      // Limit Amount
                      TextFormField(
                        controller: _limitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Limit Amount',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          prefixIcon: const Icon(Icons.attach_money, color: Colors.black),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a limit amount';
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Month Dropdown
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Month',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.black),
                        ),
                        value: _selectedMonth,
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(_months[i], style: const TextStyle(color: Colors.black)),
                          ),
                        ),
                        onChanged: (val) => setState(() => _selectedMonth = val!),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _createBudget,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Create Budget',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}