// app_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/user/providers/user_provider.dart';
import '../features/home/home_page.dart';
import '../features/user/screens/simple_login_screen.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isAuthenticated) {
          return HomePage();
        } else {
          return const SimpleLoginScreen();
        }
      },
    );
  }
}