import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Quick script to reset the database
/// Run this if you're having database schema issues during development
/// 
/// Usage: flutter run lib/reset_database.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====================================');
  print('Database Reset Tool');
  print('====================================\n');

  try {
    // Get database path
    String path = join(await getDatabasesPath(), 'expensemate.db');
    
    print('Database location: $path');
    print('\nDeleting database...');
    
    // Delete the database
    await deleteDatabase(path);
    
    print('✅ Database deleted successfully!\n');
    print('====================================');
    print('The app will create a fresh database');
    print('on the next launch.');
    print('====================================');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
