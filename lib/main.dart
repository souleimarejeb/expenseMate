import 'package:expensemate/features/widgets/main_layout.dart';
import 'package:expensemate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expensemate/features/category/CategoryPage.dart';
import 'package:expensemate/features/category/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapter (make sure CategoryAdapter is generated in category_model.g.dart)
  Hive.registerAdapter(CategoryAdapter());

  // Initialize your Hive service
  await HiveService.init();

  runApp(MyApp());
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
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
       home: const MainLayout(), 
    );
  }
}


