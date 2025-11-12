import 'package:expensemate/features/widgets/main_layout.dart';
import 'package:expensemate/routes/app_routes.dart';
import 'package:expensemate/core/services/auth_service.dart';
import 'package:expensemate/features/user/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
 ),
      onGenerateRoute: AppRoutes.generateRoute,
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().isSignedIn,
      builder: (context, signedIn, _) {
        if (signedIn) {
          return const MainLayout();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}


