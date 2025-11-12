import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:expensemate/core/services/auth_service.dart';
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/database/databaseHelper.dart';

/// Test script to debug login password issues
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====================================');
  print('Login Password Debug Test');
  print('====================================\n');

  try {
    // Initialize services
    final authService = AuthService();
    final databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase();
    
    print('✅ Database initialized\n');

    // Test 1: Register a new user
    print('Test 1: Registering a new test user...');
    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';
    final testPassword = 'TestPassword123';
    
    final registerResult = await authService.register(
      name: 'Test User',
      email: testEmail,
      password: testPassword,
    );

    print('Register result: ${registerResult['success']}');
    print('Message: ${registerResult['message']}');
    
    if (registerResult['success']) {
      final user = registerResult['user'];
      print('User created: ${user.name}');
      print('Email: ${user.email}');
      print('Preferences: ${user.preferences}');
      print('Password hash in preferences: ${user.preferences?['password']}\n');
      
      // Test 2: Try to login with the same credentials
      print('Test 2: Attempting to login with same credentials...');
      print('Email: $testEmail');
      print('Password: $testPassword\n');
      
      final loginResult = await authService.login(
        email: testEmail,
        password: testPassword,
      );

      print('Login result: ${loginResult['success']}');
      print('Message: ${loginResult['message']}');
      
      if (loginResult['success']) {
        print('✅ Login successful!');
        final loggedInUser = loginResult['user'];
        print('Logged in as: ${loggedInUser.name}');
      } else {
        print('❌ Login failed!');
        print('\nDebugging info:');
        
        // Fetch the user again to check stored password
        final userService = UserService();
        final storedUser = await userService.getUserByEmail(testEmail);
        
        if (storedUser != null) {
          print('Stored user preferences: ${storedUser.preferences}');
          print('Stored password hash: ${storedUser.preferences?['password']}');
          
          // Calculate what the hash should be
          final bytes = utf8.encode(testPassword);
          final hash = sha256.convert(bytes);
          print('Expected password hash: $hash');
          print('Hashes match: ${storedUser.preferences?['password'] == hash.toString()}');
        }
      }
    } else {
      print('❌ Registration failed: ${registerResult['message']}');
    }

  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
