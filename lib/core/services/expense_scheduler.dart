import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/recurring_expense.dart';
import 'expense_service.dart';

class ExpenseScheduler {
  static final ExpenseScheduler _instance = ExpenseScheduler._internal();
  factory ExpenseScheduler() => _instance;
  ExpenseScheduler._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final ExpenseService _expenseService = ExpenseService();
  
  Timer? _recurringTimer;
  bool _isInitialized = false;

  // Initialize the scheduler
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize notifications
    await _initializeNotifications();

    // Start the recurring expense processor
    _startRecurringProcessor();

    _isInitialized = true;
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for notifications
    await _requestNotificationPermissions();
  }

  // Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to expense screen
    print('Notification tapped: ${response.payload}');
  }

  // Start the recurring expense processor
  void _startRecurringProcessor() {
    // Check for due recurring expenses every hour
    _recurringTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _processRecurringExpenses();
    });

    // Also check immediately
    _processRecurringExpenses();
  }

  // Process due recurring expenses
  Future<void> _processRecurringExpenses() async {
    try {
      final createdExpenseIds = await _expenseService.processDueRecurringExpenses();
      
      if (createdExpenseIds.isNotEmpty) {
        await _showRecurringExpenseNotification(createdExpenseIds.length);
      }
    } catch (e) {
      print('Error processing recurring expenses: $e');
    }
  }

  // Show notification for created recurring expenses
  Future<void> _showRecurringExpenseNotification(int count) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'recurring_expenses',
      'Recurring Expenses',
      channelDescription: 'Notifications for automatically created recurring expenses',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Recurring Expenses Added',
      '$count recurring expense(s) have been automatically added to your budget.',
      notificationDetails,
      payload: 'recurring_expenses',
    );
  }

  // Schedule reminder notification for a recurring expense
  Future<void> scheduleRecurringExpenseReminder(RecurringExpense recurringExpense) async {
    if (recurringExpense.nextDueDate == null) return;

    final scheduledDate = recurringExpense.nextDueDate!.subtract(const Duration(days: 1));
    
    if (scheduledDate.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expense_reminders',
      'Expense Reminders',
      channelDescription: 'Reminders for upcoming recurring expenses',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      recurringExpense.id.hashCode,
      'Upcoming Expense Reminder',
      '${recurringExpense.title} (${recurringExpense.amount.toStringAsFixed(2)}) is due tomorrow',
      notificationDetails,
      payload: 'reminder_${recurringExpense.id}',
    );
  }

  // Schedule budget limit warning
  Future<void> scheduleBudgetWarning(String categoryId, double currentSpent, double budgetLimit) async {
    if (currentSpent < budgetLimit * 0.8) return; // Only warn at 80% of budget

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_warnings',
      'Budget Warnings',
      channelDescription: 'Warnings when approaching budget limits',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    String warningMessage;
    if (currentSpent >= budgetLimit) {
      warningMessage = 'You have exceeded your budget limit! Spent: \$${currentSpent.toStringAsFixed(2)} / \$${budgetLimit.toStringAsFixed(2)}';
    } else {
      final percentage = (currentSpent / budgetLimit * 100).round();
      warningMessage = 'You have used $percentage% of your budget. Spent: \$${currentSpent.toStringAsFixed(2)} / \$${budgetLimit.toStringAsFixed(2)}';
    }

    await _notificationsPlugin.show(
      categoryId.hashCode,
      'Budget Alert',
      warningMessage,
      notificationDetails,
      payload: 'budget_$categoryId',
    );
  }

  // Cancel all scheduled notifications for a recurring expense
  Future<void> cancelRecurringExpenseNotifications(String recurringExpenseId) async {
    await _notificationsPlugin.cancel(recurringExpenseId.hashCode);
  }

    // Schedule weekly summary notification
  Future<void> scheduleWeeklySummary() async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weekly_summary',
      'Weekly Summary',
      channelDescription: 'Weekly expense summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      'weekly_summary'.hashCode,
      'Weekly Expense Summary',
      'Check out your weekly spending summary and plan for the next week!',
      notificationDetails,
      payload: 'weekly_summary',
    );
  }

  // Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Manual trigger for processing recurring expenses (for testing)
  Future<List<String>> processRecurringExpensesManually() async {
    return await _expenseService.processDueRecurringExpenses();
  }

  // Dispose resources
  void dispose() {
    _recurringTimer?.cancel();
    _isInitialized = false;
  }

  // Smart expense predictions (fancy feature)
  Future<Map<String, dynamic>> getExpensePredictions() async {
    try {
      // Get last 3 months of expenses
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
      
      final expenses = await _expenseService.getExpensesByDateRange(startDate, endDate);
      final categorySummary = await _expenseService.getExpensesSummaryByCategory(
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate monthly averages
      Map<String, double> monthlyAverages = {};
      categorySummary.forEach((category, total) {
        monthlyAverages[category] = total / 3; // 3 months average
      });

      // Predict next month's expenses
      final now = DateTime.now();
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.day;
      
      Map<String, dynamic> predictions = {
        'monthlyAverages': monthlyAverages,
        'projectedMonthTotal': 0.0,
        'dailyAverage': 0.0,
        'trendAnalysis': <String, String>{},
      };

      // Calculate daily average and project month total
      if (expenses.isNotEmpty) {
        final currentMonthExpenses = expenses.where((expense) => 
          expense.date.year == now.year && expense.date.month == now.month
        ).toList();
        
        double currentMonthTotal = currentMonthExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
        predictions['dailyAverage'] = currentMonthTotal / daysPassed;
        predictions['projectedMonthTotal'] = (currentMonthTotal / daysPassed) * daysInMonth;
      }

      return predictions;
    } catch (e) {
      print('Error generating expense predictions: $e');
      return {};
    }
  }

  // Smart categorization suggestions based on expense title/description
  Future<String?> suggestCategory(String title, String description) async {
    final allCategories = await _expenseService.getAllCategories();
    
    final keywords = {
      'food': ['restaurant', 'food', 'coffee', 'lunch', 'dinner', 'grocery', 'pizza', 'burger'],
      'transport': ['gas', 'fuel', 'uber', 'taxi', 'bus', 'train', 'parking', 'car'],
      'shopping': ['amazon', 'store', 'clothes', 'electronics', 'shopping', 'mall'],
      'entertainment': ['movie', 'cinema', 'game', 'netflix', 'spotify', 'subscription'],
      'health': ['doctor', 'pharmacy', 'medical', 'gym', 'fitness', 'hospital'],
      'bills': ['electric', 'water', 'internet', 'phone', 'rent', 'utility'],
      'education': ['book', 'course', 'school', 'university', 'education'],
      'travel': ['hotel', 'flight', 'vacation', 'travel', 'airbnb'],
    };

    final searchText = '$title $description'.toLowerCase();
    
    for (var category in allCategories) {
      final categoryKeywords = keywords[category.id] ?? [];
      for (var keyword in categoryKeywords) {
        if (searchText.contains(keyword)) {
          return category.id;
        }
      }
    }
    
    return null; // No suggestion found
  }
}