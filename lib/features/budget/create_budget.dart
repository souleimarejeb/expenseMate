import 'package:flutter/material.dart';
import 'package:expensemate/core/models/bugets/budget.dart';
import 'package:expensemate/core/models/bugets/budget_status.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({Key? key}) : super(key: key);

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _limitController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  String? _selectedCategory;
  bool _isSubmitting = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<String> _months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  final List<String> _categories = [
    'Food', 'Transport', 'Entertainment', 'Bills', 'Shopping', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _createBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 1));

      final newBudget = Budget(
        limitAmount: double.parse(_limitController.text),
        spentAmount: 0.0,
        status: BudgetStatus.ok,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        month: _selectedMonth,
        category: _selectedCategory!,
      );

      print('✅ Created: ${newBudget.toJson()}');

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Budget created successfully!",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      _formKey.currentState!.reset();
      _limitController.clear();
      setState(() => _selectedCategory = null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'Create Budget',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
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
                  child: SingleChildScrollView(
                    
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Budget Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          label: "Category",
                          icon: Icons.category_outlined,
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                          validator: (val) =>
                              val == null ? "Please choose a category" : null,
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _limitController,
                          label: "Limit Amount",
                          icon: Icons.attach_money_outlined,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please enter a limit";
                            }
                            if (double.tryParse(val) == null) {
                              return "Enter a valid number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildMonthDropdown(),
                        const SizedBox(height: 30),

                        Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 150),
                            scale: _isSubmitting ? 0.9 : 1.0,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _createBudget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                              ),
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.add, color: Colors.white),
                              label: Text(
                                _isSubmitting ? "Creating..." : "Create Budget",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
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
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label, icon),
      value: value,
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.black)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.black),
      validator: validator,
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      decoration: _inputDecoration("Month", Icons.calendar_today_outlined),
      value: _selectedMonth,
      items: List.generate(
        12,
        (i) => DropdownMenuItem(
          value: i + 1,
          child: Text(_months[i], style: const TextStyle(color: Colors.black)),
        ),
      ),
      onChanged: (val) => setState(() => _selectedMonth = val!),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      prefixIcon: Icon(icon, color: Colors.black87),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }
}
