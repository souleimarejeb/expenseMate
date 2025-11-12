// app_wrapper.dart
import 'package:flutter/material.dart';
import '../features/home/home_page.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}