import 'package:flutter_test/flutter_test.dart';
import 'package:expensemate/core/models/user.dart';
import 'package:expensemate/core/services/user_service.dart';
import 'package:expensemate/core/database/databaseHelper.dart';

void main() {
  late UserService userService;
  late DatabaseHelper databaseHelper;

  setUp(() async {
    userService = UserService();
    databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase();
  });

  group('User CRUD Operations', () {
    test('Create a user', () async {
      final user = User(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        bio: 'Software Developer',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      expect(userId, isNotEmpty);
    });

    test('Get all users', () async {
      final users = await userService.getAllUsers();
      expect(users, isNotNull);
      expect(users, isList);
    });

    test('Get user by ID', () async {
      // Create a user first
      final user = User(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      
      // Get the user by ID
      final retrievedUser = await userService.getUserById(userId);
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, equals(userId));
      expect(retrievedUser.name, equals('Jane Smith'));
      expect(retrievedUser.email, equals('jane.smith@example.com'));
    });

    test('Get user by email', () async {
      // Create a user first
      final user = User(
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userService.createUser(user);
      
      // Get the user by email
      final retrievedUser = await userService.getUserByEmail('bob.johnson@example.com');
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.name, equals('Bob Johnson'));
      expect(retrievedUser.email, equals('bob.johnson@example.com'));
    });

    test('Update a user', () async {
      // Create a user first
      final user = User(
        name: 'Alice Williams',
        email: 'alice.williams@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      
      // Update the user
      final updatedUser = user.copyWith(
        id: userId,
        name: 'Alice Brown',
        phoneNumber: '+9876543210',
      );

      final success = await userService.updateUser(updatedUser);
      expect(success, isTrue);

      // Verify the update
      final retrievedUser = await userService.getUserById(userId);
      expect(retrievedUser!.name, equals('Alice Brown'));
      expect(retrievedUser.phoneNumber, equals('+9876543210'));
    });

    test('Delete a user', () async {
      // Create a user first
      final user = User(
        name: 'Charlie Davis',
        email: 'charlie.davis@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      
      // Delete the user
      final success = await userService.deleteUser(userId);
      expect(success, isTrue);

      // Verify the deletion
      final retrievedUser = await userService.getUserById(userId);
      expect(retrievedUser, isNull);
    });

    test('Search users', () async {
      // Create multiple users
      await userService.createUser(User(
        name: 'David Miller',
        email: 'david.miller@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await userService.createUser(User(
        name: 'Diana Moore',
        email: 'diana.moore@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Search for users
      final results = await userService.searchUsers('David');
      expect(results, isNotEmpty);
      expect(results.any((u) => u.name.contains('David')), isTrue);
    });

    test('Check if email exists', () async {
      // Create a user
      await userService.createUser(User(
        name: 'Emma Wilson',
        email: 'emma.wilson@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Check if email exists
      final exists = await userService.emailExists('emma.wilson@example.com');
      expect(exists, isTrue);

      // Check non-existent email
      final notExists = await userService.emailExists('nonexistent@example.com');
      expect(notExists, isFalse);
    });

    test('Get user count', () async {
      final initialCount = await userService.getUserCount();
      
      // Create a new user
      await userService.createUser(User(
        name: 'Frank Taylor',
        email: 'frank.taylor@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final newCount = await userService.getUserCount();
      expect(newCount, equals(initialCount + 1));
    });

    test('Update profile image', () async {
      // Create a user
      final user = User(
        name: 'Grace Anderson',
        email: 'grace.anderson@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      
      // Update profile image
      const imagePath = '/path/to/profile/image.jpg';
      final success = await userService.updateProfileImage(userId, imagePath);
      expect(success, isTrue);

      // Verify the update
      final retrievedUser = await userService.getUserById(userId);
      expect(retrievedUser!.profileImagePath, equals(imagePath));
    });

    test('Update user preferences', () async {
      // Create a user
      final user = User(
        name: 'Henry Thomas',
        email: 'henry.thomas@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userId = await userService.createUser(user);
      
      // Update preferences
      final preferences = {
        'theme': 'dark',
        'notifications': true,
        'language': 'en',
      };
      
      final success = await userService.updateUserPreferences(userId, preferences);
      expect(success, isTrue);

      // Verify the update
      final retrievedUser = await userService.getUserById(userId);
      expect(retrievedUser!.preferences, isNotNull);
      expect(retrievedUser.preferences!['theme'], equals('dark'));
    });
  });
}
