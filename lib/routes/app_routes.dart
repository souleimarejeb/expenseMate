
import 'package:expensemate/features/budget/screens/create_budget.dart';
import 'package:expensemate/features/budget/screens/budget_list.dart';
import 'package:expensemate/features/budget/screens/budget_tracking_screen.dart';
import 'package:expensemate/features/home/home_page.dart';
import 'package:expensemate/features/expenses_management/screens/expense_list_screen.dart';
import 'package:expensemate/features/expenses_management/screens/add_edit_expense_screen.dart';
import 'package:expensemate/features/expenses_management/screens/expenses_screen.dart';
import 'package:expensemate/features/category/screens/categories_screen.dart';
import 'package:expensemate/features/user/screens/simple_profile_screen.dart';
import 'package:expensemate/features/user/screens/edit_profile_screen.dart';
import 'package:expensemate/features/user/screens/profile_screen.dart';
import 'package:expensemate/features/user/screens/simple_login_screen.dart';
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
  static const String profile = '/profile';
  static const String profileNew = '/profileNew';
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
      case profile:
        return MaterialPageRoute(builder: (_) => const SimpleProfileScreen());
      case profileNew:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
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
