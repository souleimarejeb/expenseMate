import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_category.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/database/databaseHelper.dart';
import '../../widgets/attachment_widget.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const ExpenseDetailScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late AttachmentService _attachmentService;
  late ExpenseProvider _expenseProvider;
  
  @override
  void initState() {
    super.initState();
    _attachmentService = AttachmentService(DatabaseHelper());
    _expenseProvider = context.read<ExpenseProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final categories = expenseProvider.categories;
        final category = categories.firstWhere(
          (cat) => cat.id == widget.expense['categoryId'],
          orElse: () => ExpenseCategory(
            name: 'Unknown',
            description: '',
            icon: Icons.help_outline,
            color: Colors.grey,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Expense Details'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editExpense(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteExpense(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpenseHeader(category),
                const SizedBox(height: 24),
                _buildExpenseDetails(),
                const SizedBox(height: 24),
                _buildAttachmentsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseHeader(ExpenseCategory category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'expense-${widget.expense['id']}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.expense['title'] ?? 'Untitled',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '-\$${(widget.expense['amount'] ?? 0.0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Date',
              _formatDate(widget.expense['date']),
              Icons.calendar_today,
            ),
            if (widget.expense['description'] != null && 
                widget.expense['description'].toString().isNotEmpty)
              _buildDetailRow(
                'Description',
                widget.expense['description'].toString(),
                Icons.description,
              ),
            if (widget.expense['location'] != null &&
                widget.expense['location'].toString().isNotEmpty)
              _buildDetailRow(
                'Location',
                widget.expense['location'].toString(),
                Icons.location_on,
              ),
            _buildDetailRow(
              'Created',
              _formatDateTime(widget.expense['createdAt']),
              Icons.access_time,
            ),
            if (widget.expense['updatedAt'] != widget.expense['createdAt'])
              _buildDetailRow(
                'Updated',
                _formatDateTime(widget.expense['updatedAt']),
                Icons.update,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AttachmentListWidget(
              expenseId: widget.expense['id'].toString(),
              attachmentService: _attachmentService,
              allowEditing: true,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown';
    
    DateTime date;
    if (dateValue is String) {
      try {
        date = DateTime.parse(dateValue);
      } catch (e) {
        return dateValue;
      }
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      return 'Invalid date';
    }
    
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return 'Unknown';
    
    DateTime dateTime;
    if (dateTimeValue is String) {
      try {
        dateTime = DateTime.parse(dateTimeValue);
      } catch (e) {
        return dateTimeValue;
      }
    } else if (dateTimeValue is DateTime) {
      dateTime = dateTimeValue;
    } else {
      return 'Invalid datetime';
    }
    
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  void _editExpense(BuildContext context) {
    // Convert Map to Expense object for editing
    final expense = Expense.fromMap(widget.expense);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(expense: expense),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh expense data if needed
        setState(() {});
      }
    });
  }

  void _deleteExpense(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final success = await _expenseProvider.deleteExpense(widget.expense['id'].toString());
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense deleted successfully')),
            );
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete expense')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }
}