import 'package:flutter/material.dart';
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/database/databaseHelper.dart';

/// Utility script to check and fix users without passwords
/// Run this with: flutter run fix_user_passwords.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====================================');
  print('Fix User Passwords Utility');
  print('====================================\n');

  try {
    final userService = UserService();
    final databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase();
    
    print('✅ Database initialized\n');

    // Get all users
    print('Fetching all users...');
    final allUsers = await userService.getAllUsers();
    print('Found ${allUsers.length} users\n');

    int usersWithoutPassword = 0;
    int usersWithPassword = 0;

    for (var user in allUsers) {
      print('User: ${user.name} (${user.email})');
      print('  ID: ${user.id}');
      print('  Preferences: ${user.preferences}');
      
      final hasPassword = user.preferences != null && user.preferences!.containsKey('password');
      
      if (hasPassword) {
        print('  ✅ Has password');
        usersWithPassword++;
      } else {
        print('  ❌ NO PASSWORD!');
        usersWithoutPassword++;
      }
      print('');
    }

    print('Summary:');
    print('  Users with password: $usersWithPassword');
    print('  Users without password: $usersWithoutPassword');
    
    if (usersWithoutPassword > 0) {
      print('\n⚠️  Warning: Some users don\'t have passwords!');
      print('  This will cause login failures.');
      print('  You should either:');
      print('    1. Delete these users from the database');
      print('    2. Set a default password for them');
      print('    3. Re-register with these email addresses');
    }

  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
