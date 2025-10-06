
import 'package:expensemate/features/budget/create_budget.dart';
import 'package:expensemate/features/budget/screens/budget_list.dart';
import 'package:expensemate/features/home/home_page.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  // Named routes
  static const String home = '/';
  static const String createBudget = '/createBudget';
  static const String budgetList = '/budgetList';

  static const String profile = '/profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case createBudget:
        return MaterialPageRoute(builder: (_) => CreateBudgetPage());
      case budgetList:
        return MaterialPageRoute(builder: (_) => AllBudgetsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => Placeholder());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
