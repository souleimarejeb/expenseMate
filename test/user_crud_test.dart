import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:expensemate/core/database/databaseHelper.dart';
import 'package:expensemate/features/user/services/user_service.dart';
import 'package:expensemate/features/user/models/user_model.dart';
import 'package:expensemate/features/user/models/user_preferences_model.dart';
test@test.com
void main() {
  group('User CRUD Operations Test', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Use a test database
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      // Clean up after each test
      await dbHelper.close();
    });

    test('Create User', () async {
      final user = UserModel(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        phone: '+1234567890',
        bio: 'Test user for CRUD testing',
        occupation: 'Software Developer',
        monthlyIncome: 5000.0,
        dateOfBirth: DateTime(1990, 1, 1),
      );

      final userId = await UserService.createUser(user);
      expect(userId, greaterThan(0));

      final createdUser = await UserService.getUserById(userId);
      expect(createdUser, isNotNull);
      expect(createdUser!.firstName, equals('Test'));
      expect(createdUser.lastName, equals('User'));
      expect(createdUser.email, equals('test@example.com'));
    });

    test('Read User by Email', () async {
      final user = UserModel(
        firstName: 'Read',
        lastName: 'Test',
        email: 'read@example.com',
        phone: '+9876543210',
      );

      await UserService.createUser(user);
      final foundUser = await UserService.getUserByEmail('read@example.com');
      
      expect(foundUser, isNotNull);
      expect(foundUser!.firstName, equals('Read'));
      expect(foundUser.lastName, equals('Test'));
    });

    test('Update User', () async {
      final user = UserModel(
        firstName: 'Update',
        lastName: 'Test',
        email: 'update@example.com',
      );

      final userId = await UserService.createUser(user);
      final createdUser = await UserService.getUserById(userId);
      
      final updatedUser = createdUser!.copyWith(
        firstName: 'Updated',
        lastName: 'User',
        bio: 'Updated bio',
      );

      await UserService.updateUser(updatedUser);
      final fetchedUser = await UserService.getUserById(userId);
      
      expect(fetchedUser, isNotNull);
      expect(fetchedUser!.firstName, equals('Updated'));
      expect(fetchedUser.lastName, equals('User'));
      expect(fetchedUser.bio, equals('Updated bio'));
    });

    test('Delete User', () async {
      final user = UserModel(
        firstName: 'Delete',
        lastName: 'Test',
        email: 'delete@example.com',
      );

      final userId = await UserService.createUser(user);
      
      // Verify user exists
      final createdUser = await UserService.getUserById(userId);
      expect(createdUser, isNotNull);
      
      // Delete user
      await UserService.deleteUser(userId);
      
      // Verify user is deleted
      final deletedUser = await UserService.getUserById(userId);
      expect(deletedUser, isNull);
    });

    test('User Preferences CRUD', () async {
      final user = UserModel(
        firstName: 'Prefs',
        lastName: 'Test',
        email: 'prefs@example.com',
      );

      final userId = await UserService.createUser(user);
      
      final preferences = UserPreferencesModel(
        userId: userId,
        theme: 'dark',
        language: 'en',
        currency: 'USD',
        enableNotifications: true,
        enableBiometric: false,
        dateFormat: 'yyyy-MM-dd',
        timeFormat: '24h',
      );

      // Create preferences
      final prefsId = await UserService.createUserPreferences(preferences);
      expect(prefsId, greaterThan(0));

      // Read preferences
      final fetchedPrefs = await UserService.getUserPreferences(userId);
      expect(fetchedPrefs, isNotNull);
      expect(fetchedPrefs!.theme, equals('dark'));
      expect(fetchedPrefs.enableNotifications, isTrue);

      // Update preferences
      final updatedPrefs = fetchedPrefs.copyWith(
        theme: 'light',
        enableBiometric: true,
      );

      await UserService.updateUserPreferences(updatedPrefs);
      final finalPrefs = await UserService.getUserPreferences(userId);
      
      expect(finalPrefs, isNotNull);
      expect(finalPrefs!.theme, equals('light'));
      expect(finalPrefs.enableBiometric, isTrue);
    });

    test('Get All Users', () async {
      // Create multiple users
      final users = [
        UserModel(firstName: 'User1', lastName: 'Test', email: 'user1@example.com'),
        UserModel(firstName: 'User2', lastName: 'Test', email: 'user2@example.com'),
        UserModel(firstName: 'User3', lastName: 'Test', email: 'user3@example.com'),
      ];

      for (final user in users) {
        await UserService.createUser(user);
      }

      final allUsers = await UserService.getAllUsers();
      expect(allUsers.length, greaterThanOrEqualTo(3));
      
      final userEmails = allUsers.map((u) => u.email).toList();
      expect(userEmails, contains('user1@example.com'));
      expect(userEmails, contains('user2@example.com'));
      expect(userEmails, contains('user3@example.com'));
    });

    test('User Statistics', () async {
      final user = UserModel(
        firstName: 'Stats',
        lastName: 'Test',
        email: 'stats@example.com',
        monthlyIncome: 10000.0,
      );

      final userId = await UserService.createUser(user);
      
      final stats = await UserService.getUserStatistics(userId);
      expect(stats, isNotNull);
      expect(stats['totalExpenses'], isA<double>());
      expect(stats['monthlyBudget'], isA<double>());
    });
  });
}