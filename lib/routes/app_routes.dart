
import 'package:expensemate/features/budget/screens/create_budget.dart';
import 'package:expensemate/features/budget/screens/budget_list.dart';
import 'package:expensemate/features/budget/screens/budget_tracking_screen.dart';
import 'package:expensemate/features/home/home_page.dart';
import 'package:expensemate/features/expenses_management/screens/expense_list_screen.dart';
import 'package:expensemate/features/expenses_management/screens/add_edit_expense_screen.dart';
import 'package:expensemate/features/expenses_management/screens/expenses_screen.dart';
import 'package:expensemate/features/category/screens/categories_screen.dart';
import 'package:expensemate/features/widgets/main_layout.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  // Named routes
  static const String home = '/';
  static const String mainLayout = '/mainLayout';
  static const String createBudget = '/createBudget';
  static const String budgetList = '/budgetList';
  static const String budgetTracking = '/budgetTracking';
  static const String expenses = '/expenses';
  static const String expensesNew = '/expensesNew';
  static const String addExpense = '/addExpense';
  static const String categories = '/categories';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case mainLayout:
        return MaterialPageRoute(builder: (_) => MainLayout());
      case createBudget:
        return MaterialPageRoute(builder: (_) => CreateBudgetPage());
      case budgetList:
        return MaterialPageRoute(builder: (_) => AllBudgetsPage());
      case budgetTracking:
        return MaterialPageRoute(builder: (_) => const BudgetTrackingScreen());
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
      case expensesNew:
        return MaterialPageRoute(builder: (_) => ExpensesScreen());
      case addExpense:
        return MaterialPageRoute(builder: (_) => const AddEditExpenseScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => CategoriesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
