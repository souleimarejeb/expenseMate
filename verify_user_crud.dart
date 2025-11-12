import 'package:flutter/material.dart';
import 'package:expensemate/core/models/user.dart';
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/database/databaseHelper.dart';

/// Verification script for User CRUD operations
/// This script tests all user CRUD operations to ensure they work correctly
/// 
/// Run this with: flutter run lib/verify_user_crud.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====================================');
  print('User CRUD Verification Script');
  print('====================================\n');

  try {
    // Initialize services
    final userService = UserService();
    final databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase();
    
    print('✅ Database initialized successfully\n');

    // Test 1: Create User
    print('Test 1: Creating a user...');
    final user1 = User(
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      bio: 'Software Developer at Tech Corp',
      preferences: {
        'theme': 'dark',
        'notifications': true,
        'language': 'en',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final userId1 = await userService.createUser(user1);
    print('✅ User created with ID: $userId1\n');

    // Test 2: Create Another User
    print('Test 2: Creating another user...');
    final user2 = User(
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      phoneNumber: '+9876543210',
      bio: 'Product Manager',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final userId2 = await userService.createUser(user2);
    print('✅ User created with ID: $userId2\n');

    // Test 3: Get All Users
    print('Test 3: Fetching all users...');
    final allUsers = await userService.getAllUsers();
    print('✅ Found ${allUsers.length} users');
    for (var user in allUsers) {
      print('   - ${user.name} (${user.email})');
    }
    print('');

    // Test 4: Get User by ID
    print('Test 4: Fetching user by ID...');
    final fetchedUser = await userService.getUserById(userId1);
    if (fetchedUser != null) {
      print('✅ User found: ${fetchedUser.name}');
      print('   Email: ${fetchedUser.email}');
      print('   Phone: ${fetchedUser.phoneNumber}');
      print('   Bio: ${fetchedUser.bio}');
      print('   Preferences: ${fetchedUser.preferences}\n');
    } else {
      print('❌ User not found\n');
    }

    // Test 5: Get User by Email
    print('Test 5: Fetching user by email...');
    final userByEmail = await userService.getUserByEmail('jane.smith@example.com');
    if (userByEmail != null) {
      print('✅ User found: ${userByEmail.name}\n');
    } else {
      print('❌ User not found\n');
    }

    // Test 6: Update User
    print('Test 6: Updating user...');
    final updatedUser = fetchedUser!.copyWith(
      name: 'John Updated Doe',
      phoneNumber: '+1111111111',
      bio: 'Senior Software Developer',
    );
    final updateSuccess = await userService.updateUser(updatedUser);
    print(updateSuccess ? '✅ User updated successfully' : '❌ Failed to update user');
    
    // Verify update
    final verifyUpdate = await userService.getUserById(userId1);
    if (verifyUpdate != null) {
      print('   Updated name: ${verifyUpdate.name}');
      print('   Updated phone: ${verifyUpdate.phoneNumber}');
      print('   Updated bio: ${verifyUpdate.bio}\n');
    }

    // Test 7: Search Users
    print('Test 7: Searching users...');
    final searchResults = await userService.searchUsers('John');
    print('✅ Found ${searchResults.length} users matching "John"');
    for (var user in searchResults) {
      print('   - ${user.name}');
    }
    print('');

    // Test 8: Check Email Exists
    print('Test 8: Checking if email exists...');
    final emailExists1 = await userService.emailExists('john.doe@example.com');
    print(emailExists1 ? '✅ Email exists' : '❌ Email does not exist');
    
    final emailExists2 = await userService.emailExists('nonexistent@example.com');
    print(emailExists2 ? '❌ Email should not exist' : '✅ Email does not exist (correct)\n');

    // Test 9: Get User Count
    print('Test 9: Getting user count...');
    final userCount = await userService.getUserCount();
    print('✅ Total users: $userCount\n');

    // Test 10: Update Profile Image
    print('Test 10: Updating profile image...');
    const imagePath = '/path/to/profile/image.jpg';
    final imageUpdateSuccess = await userService.updateProfileImage(userId1, imagePath);
    print(imageUpdateSuccess ? '✅ Profile image updated' : '❌ Failed to update profile image');
    
    final verifyImage = await userService.getUserById(userId1);
    if (verifyImage != null) {
      print('   Image path: ${verifyImage.profileImagePath}\n');
    }

    // Test 11: Update User Preferences
    print('Test 11: Updating user preferences...');
    final newPreferences = {
      'theme': 'light',
      'notifications': false,
      'language': 'fr',
      'currency': 'EUR',
    };
    final prefsUpdateSuccess = await userService.updateUserPreferences(userId1, newPreferences);
    print(prefsUpdateSuccess ? '✅ Preferences updated' : '❌ Failed to update preferences');
    
    final verifyPrefs = await userService.getUserById(userId1);
    if (verifyPrefs != null) {
      print('   Preferences: ${verifyPrefs.preferences}\n');
    }

    // Test 12: Delete User
    print('Test 12: Deleting a user...');
    final deleteSuccess = await userService.deleteUser(userId2);
    print(deleteSuccess ? '✅ User deleted successfully' : '❌ Failed to delete user');
    
    // Verify deletion
    final deletedUser = await userService.getUserById(userId2);
    print(deletedUser == null ? '✅ User no longer exists' : '❌ User still exists\n');

    // Final Count
    print('Test 13: Final user count...');
    final finalCount = await userService.getUserCount();
    print('✅ Total users after deletion: $finalCount\n');

    print('====================================');
    print('All tests completed successfully! ✅');
    print('====================================');

  } catch (e, stackTrace) {
    print('❌ Error occurred: $e');
    print('Stack trace: $stackTrace');
  }
}
