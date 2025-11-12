import 'package:flutter/material.dart';
import 'package:expensemate/core/models/user.dart';
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/database/databaseHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('====================================');
  print('Testing User Update Functionality');
  print('====================================\n');

  try {
    // Initialize services
    final userService = UserService();
    final databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase();
    
    print('✅ Database initialized\n');

    // Create a test user
    print('Step 1: Creating test user...');
    final testUser = User(
      name: 'Test User',
      email: 'test.user@example.com',
      phoneNumber: '+1234567890',
      bio: 'Original bio',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final userId = await userService.createUser(testUser);
    print('✅ User created with ID: $userId\n');

    // Fetch the created user
    print('Step 2: Fetching user...');
    final fetchedUser = await userService.getUserById(userId);
    if (fetchedUser == null) {
      print('❌ ERROR: Could not fetch user!\n');
      return;
    }
    print('✅ User fetched successfully');
    print('   Name: ${fetchedUser.name}');
    print('   Email: ${fetchedUser.email}');
    print('   Phone: ${fetchedUser.phoneNumber}');
    print('   Bio: ${fetchedUser.bio}\n');

    // Update the user
    print('Step 3: Updating user...');
    final updatedUser = fetchedUser.copyWith(
      name: 'Updated Test User',
      phoneNumber: '+9876543210',
      bio: 'Updated bio',
    );
    
    print('Attempting to update with:');
    print('   New name: ${updatedUser.name}');
    print('   New phone: ${updatedUser.phoneNumber}');
    print('   New bio: ${updatedUser.bio}');
    print('   User ID: ${updatedUser.id}\n');

    final updateSuccess = await userService.updateUser(updatedUser);
    
    if (!updateSuccess) {
      print('❌ ERROR: Update failed!\n');
    } else {
      print('✅ Update reported success\n');
    }

    // Verify the update
    print('Step 4: Verifying update...');
    final verifyUser = await userService.getUserById(userId);
    
    if (verifyUser == null) {
      print('❌ ERROR: Could not fetch user after update!\n');
      return;
    }

    print('User after update:');
    print('   Name: ${verifyUser.name}');
    print('   Email: ${verifyUser.email}');
    print('   Phone: ${verifyUser.phoneNumber}');
    print('   Bio: ${verifyUser.bio}\n');

    // Check if changes were applied
    bool nameChanged = verifyUser.name == 'Updated Test User';
    bool phoneChanged = verifyUser.phoneNumber == '+9876543210';
    bool bioChanged = verifyUser.bio == 'Updated bio';

    print('Verification Results:');
    print('   Name changed: ${nameChanged ? "✅" : "❌"}');
    print('   Phone changed: ${phoneChanged ? "✅" : "❌"}');
    print('   Bio changed: ${bioChanged ? "✅" : "❌"}\n');

    if (nameChanged && phoneChanged && bioChanged) {
      print('🎉 SUCCESS: User update is working correctly!\n');
    } else {
      print('❌ FAILURE: User update is not working properly!\n');
    }

    // Cleanup
    print('Step 5: Cleaning up...');
    await userService.deleteUser(userId);
    print('✅ Test user deleted\n');

  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace\n');
  }
}
