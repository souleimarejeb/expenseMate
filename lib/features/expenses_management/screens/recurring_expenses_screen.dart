import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/recurring_expense.dart';
import '../providers/expense_provider.dart';

class RecurringExpensesScreen extends StatefulWidget {
  const RecurringExpensesScreen({Key? key}) : super(key: key);

  @override
  State<RecurringExpensesScreen> createState() => _RecurringExpensesScreenState();
}

class _RecurringExpensesScreenState extends State<RecurringExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.recurringExpenses.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildHeader(provider),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.recurringExpenses.length,
                  itemBuilder: (context, index) {
                    final recurringExpense = provider.recurringExpenses[index];
                    final category = provider.getCategoryById(recurringExpense.categoryId);
                    
                    return _buildRecurringExpenseCard(
                      recurringExpense,
                      category,
                      provider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringExpenseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recurring Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.recurringExpenses.length} active',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => provider.processRecurringExpenses(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Process Due'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
            Icons.repeat_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No recurring expenses',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up recurring expenses to automate your budget tracking',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddRecurringExpenseDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Recurring Expense'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringExpenseCard(
    RecurringExpense recurringExpense,
    category,
    ExpenseProvider provider,
  ) {
    final isDue = recurringExpense.isDue();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (category?.color ?? Colors.grey).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category?.icon ?? Icons.repeat,
                    color: category?.color ?? Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Expense Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recurringExpense.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DUE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(recurringExpense.amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Recurrence details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recurs ${recurringExpense.recurrenceDescription}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        recurringExpense.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: recurringExpense.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (recurringExpense.nextDueDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Next due: ${DateFormat('MMM d, yyyy').format(recurringExpense.nextDueDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDue ? Colors.red[600] : Colors.grey[600],
                            fontWeight: isDue ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            const SizedBox(height: 12),
            Row(
              children: [
                if (isDue)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.processRecurringExpenses(),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Process Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (isDue) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditRecurringExpenseDialog(recurringExpense),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDeleteRecurringExpense(recurringExpense),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecurringExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddRecurringExpenseDialog(),
    );
  }

  void _showEditRecurringExpenseDialog(RecurringExpense recurringExpense) {
    showDialog(
      context: context,
      builder: (context) => AddRecurringExpenseDialog(recurringExpense: recurringExpense),
    );
  }

  void _confirmDeleteRecurringExpense(RecurringExpense recurringExpense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Expense'),
        content: Text('Are you sure you want to delete "${recurringExpense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete recurring expense
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality coming soon')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddRecurringExpenseDialog extends StatefulWidget {
  final RecurringExpense? recurringExpense;

  const AddRecurringExpenseDialog({Key? key, this.recurringExpense}) : super(key: key);

  @override
  State<AddRecurringExpenseDialog> createState() => _AddRecurringExpenseDialogState();
}

class _AddRecurringExpenseDialogState extends State<AddRecurringExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  int _recurrenceInterval = 1;
  DateTime _startDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditing => widget.recurringExpense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final expense = widget.recurringExpense!;
      _titleController.text = expense.title;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toString();
      _recurrenceType = expense.recurrenceType;
      _recurrenceInterval = expense.recurrenceInterval;
      _startDate = expense.startDate;
      _selectedCategoryId = expense.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Recurring Expense' : 'Add Recurring Expense'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Monthly Rent',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: context.watch<ExpenseProvider>().categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 20, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategoryId = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurrenceType>(
                  value: _recurrenceType,
                  decoration: const InputDecoration(labelText: 'Recurrence'),
                  items: RecurrenceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getRecurrenceTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _recurrenceType = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _recurrenceInterval.toString(),
                  decoration: InputDecoration(
                    labelText: 'Every ${_getRecurrenceIntervalLabel()}',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final interval = int.tryParse(value);
                    if (interval != null && interval > 0) {
                      setState(() => _recurrenceInterval = interval);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveRecurringExpense,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  String _getRecurrenceTypeLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }

  String _getRecurrenceIntervalLabel() {
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        return 'day(s)';
      case RecurrenceType.weekly:
        return 'week(s)';
      case RecurrenceType.monthly:
        return 'month(s)';
      case RecurrenceType.yearly:
        return 'year(s)';
    }
  }

  void _saveRecurringExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final recurringExpense = RecurringExpense(
      id: _isEditing ? widget.recurringExpense!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId!,
      recurrenceType: _recurrenceType,
      recurrenceInterval: _recurrenceInterval,
      startDate: _startDate,
      createdAt: _isEditing ? widget.recurringExpense!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<ExpenseProvider>();
    final success = await provider.addRecurringExpense(recurringExpense);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Recurring expense updated successfully'
                : 'Recurring expense added successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Failed to update recurring expense'
                : 'Failed to add recurring expense',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}