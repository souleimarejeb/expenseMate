
import 'package:expensemate/features/budget/screens/create_budget.dart';
import 'package:expensemate/features/budget/screens/budget_list.dart';
import 'package:expensemate/features/home/home_page.dart';
import 'package:expensemate/features/expenses_management/screens/expense_list_screen.dart';
import 'package:expensemate/features/expenses_management/screens/add_edit_expense_screen.dart';
import 'package:expensemate/features/user/screens/simple_profile_screen.dart';
import 'package:expensemate/features/user/screens/edit_profile_screen.dart';
import 'package:expensemate/features/user/screens/simple_login_screen.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  // Named routes
  static const String home = '/';
  static const String createBudget = '/createBudget';
  static const String budgetList = '/budgetList';
  static const String expenses = '/expenses';
  static const String addExpense = '/addExpense';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String userSettings = '/userSettings';
  static const String userStatistics = '/userStatistics';
  static const String login = '/login';
  static const String register = '/register';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case createBudget:
        return MaterialPageRoute(builder: (_) => CreateBudgetPage());
      case budgetList:
        return MaterialPageRoute(builder: (_) => AllBudgetsPage());
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpenseListScreen());
      case addExpense:
        return MaterialPageRoute(builder: (_) => const AddEditExpenseScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const SimpleProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const SimpleLoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
