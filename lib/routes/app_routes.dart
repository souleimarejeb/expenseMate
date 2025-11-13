
import 'package:expensemate/features/budget/screens/all_budgets_page.dart';
import 'package:expensemate/features/budget/screens/create_budget.dart';

import 'package:expensemate/features/home/screens/home_page.dart';
import 'package:expensemate/features/user/screens/profile_screen.dart';
import 'package:expensemate/features/user/screens/sign_in_screen.dart';
import 'package:expensemate/features/user/screens/sign_up_screen.dart';
import 'package:expensemate/features/user/screens/edit_profile_screen.dart';
import 'package:expensemate/features/user/screens/change_password_screen.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  // Named routes
  static const String home = '/';
  static const String createBudget = '/createBudget';
  static const String budgetList = '/budgetList';

  static const String profile = '/profile';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';

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
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
